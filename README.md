# flutter_application_1

A new Flutter project.

## Supabase setup

This app uses the Supabase project **cs-elective-2** (Singapore region).
The database has a `songs` table (see `supabase/migrations/`) that the
player screen reads from.

1. Create `supabase.json` in the project root with the project URL and
   publishable key (format in `supabase.example.json`). Find them in the
   Supabase dashboard under **Project Settings → API Keys**.
   `supabase.json` is git-ignored, so your keys stay out of GitHub.
2. Install packages and run:

   ```sh
   flutter pub get
   flutter run --dart-define-from-file=supabase.json
   ```

Use the client anywhere after importing `supabase_config.dart`:

```dart
final rows = await supabase.from('songs').select();
```

## Price filter + pagination (branch `backend-filter-pagination`)

The home screen is now a shop that reads the Supabase `products` table.

1. Create the table and seed data: run
   `supabase/migrations/20261110090000_create_products.sql` in the Supabase
   SQL editor (24 products, 4 categories).
2. Run the app as above.

Features:

- **Price slider** (`RangeSlider`): limits come from the cheapest and most
  expensive product. Letting go of the slider filters with
  `.gte('price', min).lte('price', max)` in Supabase.
- **Category chips**, **edit** and **delete** on every product card.
- **Pagination**: 8 products per page, fetched with
  `.range(from, to).count(CountOption.exact)` so only one page is downloaded
  and the total count gives the page numbers.
- **State management**: Riverpod (`lib/providers/shop_providers.dart`).
  `ShopFilter` holds category, price range and page; `productPageProvider`
  watches it and re-runs the Supabase query. Changing a filter resets to
  page 1; deleting the last item on a page steps back one page.
- The original music player is still reachable from the app bar.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
