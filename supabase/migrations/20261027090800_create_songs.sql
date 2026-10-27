-- Applied to the cs-elective-2 Supabase project on 2026-10-27.
create table public.songs (
  id bigint generated always as identity primary key,
  title text not null,
  artist text not null,
  duration_seconds integer not null check (duration_seconds > 0),
  cover_url text,
  created_at timestamptz not null default now()
);

alter table public.songs enable row level security;

create policy "Songs are readable by everyone"
  on public.songs for select
  to anon, authenticated
  using (true);

insert into public.songs (title, artist, duration_seconds)
values ('Akasaka Sad', 'Rina Sawayama', 178);
