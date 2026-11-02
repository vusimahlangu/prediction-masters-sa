-- Prediction Masters SA initial schema
-- Apply in Supabase SQL Editor after creating a new project.
-- No service-role key is ever used in the browser.

create extension if not exists pgcrypto;

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id)
);

create table if not exists public.sources (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  source_type text not null check (source_type in ('official_regulator','official_competition','sports_data_provider','racing_provider','lottery_operator','other')),
  base_url text not null,
  licence_status text not null default 'pending' check (licence_status in ('pending','approved','restricted','rejected')),
  commercial_use_notes text,
  redistribution_notes text,
  checked_at timestamptz,
  created_at timestamptz not null default now(),
  created_by uuid not null default auth.uid() references auth.users(id)
);

create table if not exists public.research_records (
  id uuid primary key default gen_random_uuid(),
  sport text not null check (sport in ('Football','Rugby','Cricket','Tennis','Basketball','Horse Racing','Lottery Information','Pools / Combinations','Live / Specials')),
  competition text,
  event_name text not null,
  event_start timestamptz,
  market text not null,
  selection text not null,
  source_url text not null,
  source_checked_at timestamptz not null,
  research_method text not null,
  probability numeric(6,5) check (probability is null or (probability >= 0 and probability <= 1)),
  confidence text check (confidence is null or confidence in ('Low','Medium','High','Not assessed')),
  disclaimer text not null default 'Informational analysis only. No outcome is guaranteed.',
  status text not null default 'draft' check (status in ('draft','in_review','published','withdrawn','rejected')),
  created_by uuid not null default auth.uid() references auth.users(id),
  reviewed_by uuid references auth.users(id),
  reviewed_at timestamptz,
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.audit_log (
  id bigint generated always as identity primary key,
  actor_id uuid references auth.users(id),
  action text not null,
  table_name text not null,
  record_id uuid,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.corrections (
  id uuid primary key default gen_random_uuid(),
  research_record_id uuid not null references public.research_records(id),
  original_text jsonb not null,
  corrected_text jsonb not null,
  reason text not null,
  customer_facing_notice text,
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now()
);

create or replace function public.is_admin()
returns boolean language sql stable security definer
set search_path = public
as $$
  select exists (select 1 from public.admin_users where user_id = auth.uid());
$$;

create or replace function public.touch_updated_at()
returns trigger language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists research_touch_updated_at on public.research_records;
create trigger research_touch_updated_at before update on public.research_records
for each row execute function public.touch_updated_at();

alter table public.admin_users enable row level security;
alter table public.sources enable row level security;
alter table public.research_records enable row level security;
alter table public.audit_log enable row level security;
alter table public.corrections enable row level security;

-- Admin roster cannot be read or modified by ordinary users.
create policy "admin roster read own" on public.admin_users
for select to authenticated using (user_id = auth.uid() or public.is_admin());
create policy "admin roster admin manage" on public.admin_users
for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- Sources are internal; admins only.
create policy "sources admin all" on public.sources
for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- Research records are private to admins by default.
create policy "research admin read" on public.research_records
for select to authenticated using (public.is_admin());
create policy "research admin insert" on public.research_records
for insert to authenticated with check (public.is_admin() and created_by = auth.uid());
create policy "research admin update" on public.research_records
for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "research admin delete draft only" on public.research_records
for delete to authenticated using (public.is_admin() and status in ('draft','rejected'));

create policy "audit admin read" on public.audit_log
for select to authenticated using (public.is_admin());
create policy "audit admin insert" on public.audit_log
for insert to authenticated with check (public.is_admin() and actor_id = auth.uid());

create policy "corrections admin all" on public.corrections
for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- Public view exposes only explicitly published, non-withdrawn records and excludes private research notes/source URL.
create or replace view public.predictions_public
as
select id, sport, competition, event_name, event_start, market, selection,
       published_at, probability, confidence, source_checked_at, disclaimer
from public.research_records
where status = 'published' and published_at is not null;

grant select on public.predictions_public to anon, authenticated;

-- Approval must be performed by an authenticated admin. This records reviewer and publication timestamp.
create or replace function public.approve_research_record(record_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin() then
    raise exception 'Not authorised';
  end if;
  update public.research_records
  set status = 'published',
      reviewed_by = auth.uid(),
      reviewed_at = now(),
      published_at = now()
  where id = record_id and status in ('draft','in_review');
  if not found then
    raise exception 'Record not found or not eligible for approval';
  end if;
  insert into public.audit_log(actor_id,action,table_name,record_id,details)
  values(auth.uid(),'publish','research_records',record_id,'{"status":"published"}'::jsonb);
end;
$$;
grant execute on function public.approve_research_record(uuid) to authenticated;

-- Audit all research changes (no secrets should ever be stored in research fields).
create or replace function public.log_research_change()
returns trigger language plpgsql security definer
set search_path = public
as $$
declare rid uuid;
begin
  rid := coalesce(new.id, old.id);
  insert into public.audit_log(actor_id,action,table_name,record_id,details)
  values(auth.uid(),tg_op,'research_records',rid,jsonb_build_object('new_status',case when tg_op='DELETE' then null else new.status end));
  if tg_op='DELETE' then return old; else return new; end if;
end;
$$;
drop trigger if exists research_audit_trigger on public.research_records;
create trigger research_audit_trigger after insert or update or delete on public.research_records
for each row execute function public.log_research_change();
