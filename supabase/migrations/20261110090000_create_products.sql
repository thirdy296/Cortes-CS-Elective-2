-- Products table for the shop (price filter + pagination activity).
-- Run this in the Supabase SQL editor (or `supabase db push`).
create table if not exists public.products (
  id bigint generated always as identity primary key,
  name text not null,
  description text not null default '',
  category text not null,
  price numeric(10, 2) not null check (price >= 0),
  image_url text,
  created_at timestamptz not null default now()
);

-- Speeds up the price range filter + ordering used by pagination.
create index if not exists products_price_idx on public.products (price);
create index if not exists products_category_idx on public.products (category);

alter table public.products enable row level security;

-- Class project: the app uses the publishable (anon) key with no login,
-- so anon can read, update and delete. Lock these down once auth is added.
create policy "Products are readable by everyone"
  on public.products for select
  to anon, authenticated
  using (true);

create policy "Products are updatable by everyone"
  on public.products for update
  to anon, authenticated
  using (true)
  with check (true);

create policy "Products are deletable by everyone"
  on public.products for delete
  to anon, authenticated
  using (true);

-- Seed data: 24 products across 4 categories and a wide price spread,
-- enough for 3+ pages at 8 per page.
insert into public.products (name, description, category, price, image_url) values
  ('Wireless Earbuds', 'Bluetooth 5.3 earbuds with charging case.', 'Electronics', 1299.00, 'https://picsum.photos/seed/earbuds/400/400'),
  ('Smart Watch', 'Fitness tracking, heart rate and notifications.', 'Electronics', 3499.00, 'https://picsum.photos/seed/watch/400/400'),
  ('Power Bank 20000mAh', 'Fast-charging USB-C power bank.', 'Electronics', 999.00, 'https://picsum.photos/seed/powerbank/400/400'),
  ('Mechanical Keyboard', 'Hot-swappable switches, RGB backlight.', 'Electronics', 2799.00, 'https://picsum.photos/seed/keyboard/400/400'),
  ('Gaming Mouse', 'Lightweight 16000 DPI mouse.', 'Electronics', 899.00, 'https://picsum.photos/seed/mouse/400/400'),
  ('Bluetooth Speaker', 'Waterproof portable speaker.', 'Electronics', 1599.00, 'https://picsum.photos/seed/speaker/400/400'),
  ('Noise-Cancelling Headphones', 'Over-ear ANC headphones, 30h battery.', 'Electronics', 5999.00, 'https://picsum.photos/seed/headphones/400/400'),
  ('Oversized Hoodie', 'Cotton-blend fleece hoodie.', 'Clothing', 899.00, 'https://picsum.photos/seed/hoodie/400/400'),
  ('Graphic Tee', 'Relaxed-fit printed t-shirt.', 'Clothing', 399.00, 'https://picsum.photos/seed/tee/400/400'),
  ('Denim Jacket', 'Classic washed denim jacket.', 'Clothing', 1899.00, 'https://picsum.photos/seed/denim/400/400'),
  ('Running Shoes', 'Breathable mesh running shoes.', 'Clothing', 2499.00, 'https://picsum.photos/seed/shoes/400/400'),
  ('Baseball Cap', 'Adjustable cotton cap.', 'Clothing', 299.00, 'https://picsum.photos/seed/cap/400/400'),
  ('Cargo Pants', 'Utility pants with six pockets.', 'Clothing', 1199.00, 'https://picsum.photos/seed/cargo/400/400'),
  ('Ceramic Mug', '350ml stoneware mug.', 'Home', 199.00, 'https://picsum.photos/seed/mug/400/400'),
  ('Desk Lamp', 'LED lamp with 3 color temperatures.', 'Home', 749.00, 'https://picsum.photos/seed/lamp/400/400'),
  ('Throw Pillow', 'Soft linen pillow, 45x45cm.', 'Home', 349.00, 'https://picsum.photos/seed/pillow/400/400'),
  ('Scented Candle', 'Vanilla soy wax candle.', 'Home', 259.00, 'https://picsum.photos/seed/candle/400/400'),
  ('Wall Clock', 'Minimalist silent wall clock.', 'Home', 549.00, 'https://picsum.photos/seed/clock/400/400'),
  ('Air Fryer', '4L digital air fryer.', 'Home', 3299.00, 'https://picsum.photos/seed/airfryer/400/400'),
  ('Notebook Set', 'Three A5 dotted notebooks.', 'Stationery', 249.00, 'https://picsum.photos/seed/notebook/400/400'),
  ('Gel Pens (12 pcs)', 'Assorted colors, 0.5mm tip.', 'Stationery', 159.00, 'https://picsum.photos/seed/pens/400/400'),
  ('Desk Organizer', 'Bamboo organizer with 5 slots.', 'Stationery', 459.00, 'https://picsum.photos/seed/organizer/400/400'),
  ('Planner 2027', 'Weekly planner, hardcover.', 'Stationery', 399.00, 'https://picsum.photos/seed/planner/400/400'),
  ('Backpack', 'Laptop backpack, fits 15.6 inch.', 'Stationery', 1499.00, 'https://picsum.photos/seed/backpack/400/400');
