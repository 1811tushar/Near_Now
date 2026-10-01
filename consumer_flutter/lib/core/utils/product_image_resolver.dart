
/// Resolves a real, correctly-matching photo for a product/category name,
/// overriding the backend's broken `picsum.photos/seed/<name>` URLs (those
/// are a *deterministic random* photo per seed string — not a keyword
/// search — so they never actually match the product).
///
/// This is intentionally a Flutter-layer override, not a backend change:
/// `backend/SeedData.java` is left untouched. Every entry below was
/// individually verified (correct subject, free "Unsplash License") before
/// being added — see the design-redesign handoff for the sourcing process.
///
/// STATUS: 8 of 96 catalog products verified so far (Fruits & Veg: Banana,
/// Apple, Tomato, Potato; Dairy: Milk, Eggs; Bakery: Bread; Dry Fruits:
/// Almonds). Remaining products fall back to a clean tinted icon chip
/// (see ProductCard._fallbackTile and equivalents) rather than a wrong
/// photo. Extending this to meaningful further coverage is real,
/// ongoing work — manual verification (search, confirm the photo
/// actually depicts the product, confirm free license, then add) does
/// not scale well to all 96 by hand; the practical path for full
/// coverage is a one-time script against Unsplash's official Search API
/// (needs a free API key), verified in bulk rather than one-by-one here.
class ProductImageResolver {
  ProductImageResolver._();

  static const Map<String, String> _verified = {
    'Fresh Banana':
        'https://images.unsplash.com/photo-1676495706102-ca1be8fdf676?w=400&h=400&fit=crop&auto=format&q=70',
    'Royal Gala Apple':
        'https://images.unsplash.com/photo-1568702846914-96b305d2aaeb?w=400&h=400&fit=crop&auto=format&q=70',
    'Tomato':
        'https://images.unsplash.com/photo-1627888086271-6c8546b2977c?w=400&h=400&fit=crop&auto=format&q=70',
    'Potato':
        'https://images.unsplash.com/photo-1508313880080-c4bef0730395?w=400&h=400&fit=crop&auto=format&q=70',
    'Toned Milk':
        'https://images.unsplash.com/photo-1596151163116-98a5033814c2?w=400&h=400&fit=crop&auto=format&q=70',
    'Bread':
        'https://images.unsplash.com/photo-1650123465396-a065c2340715?w=400&h=400&fit=crop&auto=format&q=70',
    'Farm Fresh Eggs':
        'https://images.unsplash.com/photo-1647813846512-2ebc1eb15628?w=400&h=400&fit=crop&auto=format&q=70',
    'Almonds':
        'https://images.unsplash.com/photo-1508779018996-601e37fa274e?w=400&h=400&fit=crop&auto=format&q=70',
  };

  /// Returns a verified, correctly-matching photo URL for [productName],
  /// or null if this product hasn't been through verification yet — callers
  /// should fall back to a tinted icon chip (never picsum, never emoji).
  static String? resolve(String productName) => _verified[productName];

  static bool hasVerifiedPhoto(String productName) =>
      _verified.containsKey(productName);
}
