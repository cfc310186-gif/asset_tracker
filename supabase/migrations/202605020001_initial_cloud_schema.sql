create or replace function public.set_updated_at()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table public.loans (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  type text not null check (btrim(type) <> ''),
  name text not null check (btrim(name) <> ''),
  principal numeric not null check (principal >= 0),
  remaining_balance numeric not null check (remaining_balance >= 0),
  interest_rate numeric not null check (interest_rate >= 0),
  term_months integer not null check (term_months >= 0),
  monthly_payment numeric not null check (monthly_payment >= 0),
  currency text not null check (btrim(currency) <> ''),
  has_grace_period boolean not null default false,
  grace_period_months integer check (grace_period_months is null or grace_period_months >= 0),
  grace_period_end_date date,
  start_date date not null,
  source_type text not null check (btrim(source_type) <> ''),
  source_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint loans_id_user_id_key unique (id, user_id)
);

create table public.stock_holdings (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  symbol text not null check (btrim(symbol) <> ''),
  market text not null check (btrim(market) <> ''),
  name text not null check (btrim(name) <> ''),
  quantity integer not null check (quantity > 0),
  avg_cost numeric not null check (avg_cost >= 0),
  currency text not null check (btrim(currency) <> ''),
  is_margin boolean not null default false,
  margin_amount numeric check (margin_amount is null or margin_amount >= 0),
  linked_loan_id uuid,
  latest_price numeric check (latest_price is null or latest_price >= 0),
  price_updated_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint stock_holdings_linked_loan_user_fk
    foreign key (linked_loan_id, user_id) references public.loans(id, user_id)
    on delete set null (linked_loan_id)
);

create table public.cash_accounts (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (btrim(name) <> ''),
  bank_name text,
  balance numeric not null check (balance >= 0),
  currency text not null check (btrim(currency) <> ''),
  annual_rate numeric check (annual_rate is null or annual_rate >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.real_estate_assets (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (btrim(name) <> ''),
  address text not null check (btrim(address) <> ''),
  estimated_value numeric not null check (estimated_value >= 0),
  purchase_price numeric not null check (purchase_price >= 0),
  purchase_date date not null,
  currency text not null check (btrim(currency) <> ''),
  has_mortgage boolean not null default false,
  linked_loan_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint real_estate_assets_linked_loan_user_fk
    foreign key (linked_loan_id, user_id) references public.loans(id, user_id)
    on delete set null (linked_loan_id)
);

create table public.transactions (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  asset_type text not null check (asset_type in ('stock', 'cash', 'real_estate', 'loan')),
  asset_id uuid not null,
  kind text not null check (kind in ('buy', 'sell', 'deposit', 'withdraw', 'dividend', 'adjust')),
  quantity numeric check (quantity is null or quantity >= 0),
  price numeric check (price is null or price >= 0),
  amount numeric not null,
  currency text not null check (btrim(currency) <> ''),
  occurred_at timestamptz not null,
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.net_worth_snapshots (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  captured_at timestamptz not null,
  display_currency text not null check (btrim(display_currency) <> ''),
  total_assets numeric not null check (total_assets >= 0),
  total_liabilities numeric not null check (total_liabilities >= 0),
  net_worth numeric not null,
  breakdown jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint net_worth_snapshots_user_captured_currency_key
    unique (user_id, captured_at, display_currency),
  constraint net_worth_snapshots_breakdown_object_check
    check (jsonb_typeof(breakdown) = 'object')
);

create table public.exchange_rates (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  from_currency text not null check (btrim(from_currency) <> ''),
  to_currency text not null check (btrim(to_currency) <> ''),
  rate numeric not null check (rate > 0),
  fetched_at timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index loans_user_id_idx on public.loans (user_id);
create index loans_user_type_idx on public.loans (user_id, type);
create index loans_user_source_idx on public.loans (user_id, source_type, source_id);
create index loans_user_deleted_at_idx on public.loans (user_id, deleted_at);

create index stock_holdings_user_id_idx on public.stock_holdings (user_id);
create index stock_holdings_user_symbol_market_idx on public.stock_holdings (user_id, symbol, market);
create index stock_holdings_user_linked_loan_idx on public.stock_holdings (user_id, linked_loan_id);
create index stock_holdings_user_deleted_at_idx on public.stock_holdings (user_id, deleted_at);

create index cash_accounts_user_id_idx on public.cash_accounts (user_id);
create index cash_accounts_user_currency_idx on public.cash_accounts (user_id, currency);
create index cash_accounts_user_deleted_at_idx on public.cash_accounts (user_id, deleted_at);

create index real_estate_assets_user_id_idx on public.real_estate_assets (user_id);
create index real_estate_assets_user_linked_loan_idx on public.real_estate_assets (user_id, linked_loan_id);
create index real_estate_assets_user_deleted_at_idx on public.real_estate_assets (user_id, deleted_at);

create index transactions_user_id_idx on public.transactions (user_id);
create index transactions_user_asset_idx on public.transactions (user_id, asset_type, asset_id);
create index transactions_user_occurred_at_idx on public.transactions (user_id, occurred_at desc);
create index transactions_user_deleted_at_idx on public.transactions (user_id, deleted_at);

create index net_worth_snapshots_user_id_idx on public.net_worth_snapshots (user_id);
create index net_worth_snapshots_user_captured_at_idx on public.net_worth_snapshots (user_id, captured_at desc);
create index net_worth_snapshots_user_deleted_at_idx on public.net_worth_snapshots (user_id, deleted_at);

create index exchange_rates_user_id_idx on public.exchange_rates (user_id);
create index exchange_rates_user_pair_fetched_at_idx
  on public.exchange_rates (user_id, from_currency, to_currency, fetched_at desc);
create index exchange_rates_user_deleted_at_idx on public.exchange_rates (user_id, deleted_at);

alter table public.loans enable row level security;
alter table public.stock_holdings enable row level security;
alter table public.cash_accounts enable row level security;
alter table public.real_estate_assets enable row level security;
alter table public.transactions enable row level security;
alter table public.net_worth_snapshots enable row level security;
alter table public.exchange_rates enable row level security;

create policy loans_select_own on public.loans
  for select using (user_id = auth.uid());
create policy loans_insert_own on public.loans
  for insert with check (user_id = auth.uid());
create policy loans_update_own on public.loans
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy loans_delete_own on public.loans
  for delete using (user_id = auth.uid());

create policy stock_holdings_select_own on public.stock_holdings
  for select using (user_id = auth.uid());
create policy stock_holdings_insert_own on public.stock_holdings
  for insert with check (user_id = auth.uid());
create policy stock_holdings_update_own on public.stock_holdings
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy stock_holdings_delete_own on public.stock_holdings
  for delete using (user_id = auth.uid());

create policy cash_accounts_select_own on public.cash_accounts
  for select using (user_id = auth.uid());
create policy cash_accounts_insert_own on public.cash_accounts
  for insert with check (user_id = auth.uid());
create policy cash_accounts_update_own on public.cash_accounts
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy cash_accounts_delete_own on public.cash_accounts
  for delete using (user_id = auth.uid());

create policy real_estate_assets_select_own on public.real_estate_assets
  for select using (user_id = auth.uid());
create policy real_estate_assets_insert_own on public.real_estate_assets
  for insert with check (user_id = auth.uid());
create policy real_estate_assets_update_own on public.real_estate_assets
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy real_estate_assets_delete_own on public.real_estate_assets
  for delete using (user_id = auth.uid());

create policy transactions_select_own on public.transactions
  for select using (user_id = auth.uid());
create policy transactions_insert_own on public.transactions
  for insert with check (user_id = auth.uid());
create policy transactions_update_own on public.transactions
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy transactions_delete_own on public.transactions
  for delete using (user_id = auth.uid());

create policy net_worth_snapshots_select_own on public.net_worth_snapshots
  for select using (user_id = auth.uid());
create policy net_worth_snapshots_insert_own on public.net_worth_snapshots
  for insert with check (user_id = auth.uid());
create policy net_worth_snapshots_update_own on public.net_worth_snapshots
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy net_worth_snapshots_delete_own on public.net_worth_snapshots
  for delete using (user_id = auth.uid());

create policy exchange_rates_select_own on public.exchange_rates
  for select using (user_id = auth.uid());
create policy exchange_rates_insert_own on public.exchange_rates
  for insert with check (user_id = auth.uid());
create policy exchange_rates_update_own on public.exchange_rates
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy exchange_rates_delete_own on public.exchange_rates
  for delete using (user_id = auth.uid());

create trigger loans_set_updated_at
  before update on public.loans
  for each row execute function public.set_updated_at();

create trigger stock_holdings_set_updated_at
  before update on public.stock_holdings
  for each row execute function public.set_updated_at();

create trigger cash_accounts_set_updated_at
  before update on public.cash_accounts
  for each row execute function public.set_updated_at();

create trigger real_estate_assets_set_updated_at
  before update on public.real_estate_assets
  for each row execute function public.set_updated_at();

create trigger transactions_set_updated_at
  before update on public.transactions
  for each row execute function public.set_updated_at();

create trigger net_worth_snapshots_set_updated_at
  before update on public.net_worth_snapshots
  for each row execute function public.set_updated_at();

create trigger exchange_rates_set_updated_at
  before update on public.exchange_rates
  for each row execute function public.set_updated_at();
