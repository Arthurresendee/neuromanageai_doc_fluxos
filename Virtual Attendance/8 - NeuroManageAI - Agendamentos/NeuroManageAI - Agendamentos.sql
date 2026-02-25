create table public.contatos_agente (
  id serial not null,
  user_number text null,
  user_name text null,
  user_profile text null,
  agente text null default 'recepcionista'::text,
  role text null,
  status text null,
  email text null,
  interesse_duvida text null,
  created_at timestamp without time zone null default now(),
  constraint contatos_agente_pkey primary key (id),
  constraint contatos_agente_user_number_key unique (user_number)
) TABLESPACE pg_default;