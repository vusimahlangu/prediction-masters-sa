-- Prediction Masters SA v4: require a different administrator to approve a submitted record.
-- Apply AFTER 0001_initial_schema.sql in Supabase SQL Editor.
create or replace function public.approve_research_record(record_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare author_id uuid; current_status text;
begin
  if not public.is_admin() then raise exception 'Not authorised'; end if;
  select created_by, status into author_id, current_status
  from public.research_records where id = record_id for update;
  if not found then raise exception 'Record not found'; end if;
  if current_status <> 'in_review' then raise exception 'Record must be submitted for review first'; end if;
  if author_id = auth.uid() then raise exception 'Independent approval required: the author cannot approve their own record'; end if;
  update public.research_records
  set status = 'published', reviewed_by = auth.uid(), reviewed_at = now(), published_at = now()
  where id = record_id;
  insert into public.audit_log(actor_id, action, table_name, record_id, details)
  values(auth.uid(), 'publish', 'research_records', record_id, jsonb_build_object('status','published','independent_review',true));
end;
$$;
grant execute on function public.approve_research_record(uuid) to authenticated;
