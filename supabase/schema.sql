
-- TASKORA DATABASE SCHEMA
-- Run in a NEW Supabase project

create extension if not exists pgcrypto;

-- 1. User Profiles
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  role text not null default 'worker'
    check (role in ('worker', 'client')),
  created_at timestamptz default now()
);

-- 2. Wallet Accounts
create table public.wallet_accounts (
  user_id uuid primary key references public.profiles(id),
  balance numeric(12,2) not null default 0
    check (balance >= 0),
  updated_at timestamptz default now()
);

-- 3. Tasks
create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.profiles(id),
  title text not null,
  description text not null,
  category text not null,
  reward_per_worker numeric(12,2) not null
    check (reward_per_worker > 0),
  slots integer not null check (slots > 0),
  commission_rate numeric(5,2) not null default 20,
  status text not null default 'draft'
    check (status in ('draft', 'published', 'paused', 'completed')),
  created_at timestamptz default now()
);

-- 4. Task Submissions
create table public.submissions (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references public.tasks(id),
  worker_id uuid not null references public.profiles(id),
  proof text not null,
  status text not null default 'pending'
    check (status in ('pending', 'approved', 'rejected')),
  created_at timestamptz default now(),
  unique(task_id, worker_id)
);

-- 5. Wallet Transactions
create table public.wallet_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  amount numeric(12,2) not null check (amount > 0),
  type text not null check (
    type in ('deposit', 'task_payment', 'earning', 'withdrawal', 'refund')
  ),
  reference_id uuid,
  description text,
  created_at timestamptz default now()
);

-- 6. Manual Payment Requests
create table public.payment_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  method text not null check (method in ('bkash', 'nagad')),
  sender_number text not null,
  transaction_id text not null,
  amount numeric(12,2) not null check (amount > 0),
  status text not null default 'pending'
    check (status in ('pending', 'approved', 'rejected')),
  created_at timestamptz default now(),
  unique(method, transaction_id)
);

-- 7. Withdrawal Requests
create table public.withdrawal_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  method text not null check (method in ('bkash', 'nagad')),
  destination_number text not null,
  amount numeric(12,2) not null check (amount > 0),
  status text not null default 'pending'
    check (status in ('pending', 'approved', 'rejected')),
  created_at timestamptz default now()
);

-- Automatically create profile and wallet on signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', '')
  );

  insert into public.wallet_accounts (user_id)
  values (new.id);

  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Enable Row Level Security
alter table public.profiles enable row level security;
alter table public.wallet_accounts enable row level security;
alter table public.tasks enable row level security;
alter table public.submissions enable row level security;
alter table public.wallet_transactions enable row level security;
alter table public.payment_requests enable row level security;
alter table public.withdrawal_requests enable row level security;

-- Profiles: users can read their own profile
create policy "Read own profile"
on public.profiles for select
to authenticated
using (id = (select auth.uid()));

-- Wallet: users can read their own balance
create policy "Read own wallet"
on public.wallet_accounts for select
to authenticated
using (user_id = (select auth.uid()));

-- Published tasks are publicly readable
create policy "Read published tasks"
on public.tasks for select
to anon, authenticated
using (status = 'published');

-- Clients can create their own draft tasks
create policy "Create own tasks"
on public.tasks for insert
to authenticated
with check (
  client_id = (select auth.uid())
  and status = 'draft'
);

-- Workers can create their own submissions
create policy "Create own submissions"
on public.submissions for insert
to authenticated
with check (
  worker_id = (select auth.uid())
  and status = 'pending'
);

-- Users can read their own submissions
create policy "Read own submissions"
on public.submissions for select
to authenticated
using (worker_id = (select auth.uid()));

-- Users can read their own transactions
create policy "Read own transactions"
on public.wallet_transactions for select
to authenticated
using (user_id = (select auth.uid()));

-- Users can submit manual payment requests
create policy "Create own payment requests"
on public.payment_requests for insert
to authenticated
with check (user_id = (select auth.uid()) and status = 'pending');

create policy "Read own payment requests"
on public.payment_requests for select
to authenticated
using (user_id = (select auth.uid()));

-- Users can request withdrawals
create policy "Create own withdrawal requests"
on public.withdrawal_requests for insert
to authenticated
with check (user_id = (select auth.uid()) and status = 'pending');

create policy "Read own withdrawal requests"
on public.withdrawal_requests for select
to authenticated
using (user_id = (select auth.uid()));

-- IMPORTANT:
-- No client-side wallet balance updates.
-- No client-side payment approvals.
-- Admin operations must use a secure server-side backend.
  
