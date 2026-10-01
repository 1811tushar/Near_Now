# NearNow — Consumer App (Flutter)

The customer-facing mobile app for NearNow, a Blinkit/Zepto-style
quick-commerce platform. Talks to the Spring Boot backend
(`../backend`) and, through it, the AI microservice (`../ai-service`)
for search, recommendations, and the shopping/order-support
assistants.

## Design system

- **Palette:** Meadow (`#146C43`, primary), Citrus (`#C6E86B`, accent),
  Paper (`#FAF8F1`, background), Ink (`#12261C`, text)
- **Typography:** Manrope, via `google_fonts`
- **Iconography:** Material Symbols for nav/UI chrome; custom flat
  `CustomPainter` illustrations for the 8 core product categories
  (`core/widgets/category_icon_illustrations.dart`) — no emoji
  anywhere in the shipped UI
- **Product imagery:** the backend's seed images
  (`picsum.photos/seed/<name>`) are deterministic *placeholders*, not
  actually keyword-matched to the product — `ProductImageResolver`
  (`core/utils/product_image_resolver.dart`) overrides them with
  individually-verified real photos where available, and falls back to
  a clean tinted icon chip rather than ever showing a wrong photo.
  Coverage is partial and documented in that file's own comment —
  extending it is real, ongoing work, not a one-time fix.
- **Grids:** product grids (Category, Search, Wishlist) use
  `flutter_staggered_grid_view`'s `MasonryGridView` rather than a
  fixed-height `GridView`, so cards with variable content (discount
  badge or not, 1 vs 2-line names) never overflow regardless of
  device, font-scale setting, or product name length.
- **Accessibility:** system text-scale is clamped to 0.9x–1.2x
  app-wide (`main.dart`) — respects accessibility settings within a
  range the UI is actually tested against, rather than leaving fixed
  layouts to break at 1.5x–2x scale, the same trade-off major
  commerce apps (Swiggy, Zomato, Amazon) make.

## Known gaps (honestly, not hidden)

- Product photo coverage is partial (see `ProductImageResolver`)
- Review auto-summary (built end-to-end on the backend + AI service)
  is **not yet called from this app** — `ReviewService` has no method
  for it yet
- Dark theme is not implemented yet (light theme only), though the
  color tokens were built with a dark variant in mind for later
- Return/refund screen intentionally shows an honest "not available
  yet" state — there is no backend endpoint for it

## Running locally