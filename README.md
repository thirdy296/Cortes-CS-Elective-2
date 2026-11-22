# Brew & Bean: Flutter + Supabase coffee shop (final exam)

A role-based e-commerce app. **Admins** manage products, categories and
orders; **customers** browse, filter, build a cart, check out and review
their orders.

| Area | Used |
|---|---|
| State management | Riverpod (`lib/providers`) |
| Backend | Supabase Auth, Postgres, Row Level Security |
| Sign-in | Email + password, and Google |
| Images | Supabase Storage bucket `product-images` |

## Project structure

```
lib/
  models/      plain data classes (Product, Category, Profile, Order, CartLine)
  services/    the ONLY code that talks to Supabase
  providers/   Riverpod state; screens call these, these call services
  screens/     pages (auth, admin home, customer home, cart, orders, forms)
  widgets/     reusable UI (product card, filters, state views, order tile)
  theme/       app-wide coffee theme
  utils/       error messages and formatters
supabase/migrations/   SQL for tables, functions, triggers, RLS, storage
```

## Database (run once)

Open Supabase → **SQL Editor**, paste
`supabase/migrations/20261122090000_final_exam_schema.sql` and **Run**.
It creates:

- Tables `roles`, `profiles`, `categories`, `products`, `orders`,
  `order_items` (with name and unit-price snapshots), plus seed data.
- `is_admin()` and the `handle_new_user()` trigger on `auth.users`, which
  creates a **customer** profile for every new account (email or Google).
- `place_order(items)`: checkout in **one transaction**. It locks each
  product, checks stock, reads the price and name from the database,
  saves the order and its items, reduces stock and sets status `done`. Any
  failure rolls everything back.
- RLS on every table, matching the permission table. Column privileges
  stop customers from changing `profiles.role_id` and stop admins from
  changing anything on an order except `status`.
- Storage bucket `product-images` (admin-only upload).

**Make yourself an admin** after signing up once:

```sql
update public.profiles
set role_id = (select id from public.roles where role = 'admin')
where email = 'you@example.com';
```

### Why hiding a button is not security

The app hides Add/Edit/Delete from customers, but anyone can call the
Supabase API directly with the publishable key. The real protection is
RLS: `create product` checks `is_admin()`, so a customer's insert is
rejected by Postgres no matter what the UI shows.

## Google sign-in setup

1. Google Cloud Console → APIs & Services → Credentials → **Create OAuth
   client ID** → Web application.
   Authorized redirect URI: `https://<project-ref>.supabase.co/auth/v1/callback`
2. Supabase → Authentication → Sign In / Providers → **Google** → enable,
   paste Client ID and Client secret, save.
3. Supabase → Authentication → URL Configuration → Redirect URLs:
   `http://localhost:3000/**` and `io.supabase.cselective2://login-callback/`

## Run

Create `supabase.json` (git-ignored, format in `supabase.example.json`), then:

```sh
flutter pub get
flutter run -d chrome --web-port 3000 --dart-define-from-file=supabase.json
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
