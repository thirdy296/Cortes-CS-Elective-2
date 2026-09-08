class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;
  final String brand;
  final double weightOz;
  final String gripSize;
  final String faceMaterial;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.brand,
    required this.weightOz,
    required this.gripSize,
    required this.faceMaterial,
  });
}

const List<Product> sampleProducts = [
  Product(
    id: '1',
    name: 'Selkirk SLK Halo XL',
    price: 8399.00,
    imageUrl: 'assets/paddles/selkirk_halo.jpg',
    description:
        'A premium elongated paddle featuring a Raw Carbon Fiber face for unmatched spin. '
        'Designed for power players who love a larger sweet spot.',
    brand: 'Selkirk',
    weightOz: 8.1,
    gripSize: '4.25 in',
    faceMaterial: 'Carbon Fiber',
  ),
  Product(
    id: '2',
    name: 'Joola Ben Johns Hyperion',
    price: 11199.00,
    imageUrl: 'assets/paddles/joola_hyperion.jpg',
    description:
        'Signature paddle of world #1 Ben Johns. Carbon Friction surface delivers elite spin '
        'and precision. A top choice for competitive players.',
    brand: 'Joola',
    weightOz: 7.9,
    gripSize: '4.125 in',
    faceMaterial: 'Carbon Fiber',
  ),
  Product(
    id: '3',
    name: 'Paddletek Tempest Wave Pro',
    price: 6719.00,
    imageUrl: 'assets/paddles/paddletek_tempest.jpg',
    description:
        'Built with a Fiberglass face and polymer core for a soft touch and consistent '
        'ball control. Great all-around paddle for intermediate players.',
    brand: 'Paddletek',
    weightOz: 7.6,
    gripSize: '4.25 in',
    faceMaterial: 'Fiberglass',
  ),
  Product(
    id: '4',
    name: 'Onix Graphite Z5',
    price: 4999.00,
    imageUrl: 'assets/paddles/onix_z5.jpg',
    description:
        'One of the best-selling paddles in pickleball history. Graphite face with a '
        'Nomex honeycomb core for a powerful, responsive feel.',
    brand: 'Onix',
    weightOz: 7.5,
    gripSize: '4.0 in',
    faceMaterial: 'Graphite',
  ),
  Product(
    id: '5',
    name: 'Engage Pursuit EX 6.0',
    price: 9499.00,
    imageUrl: 'assets/paddles/engage_pursuit.jpg',
    description:
        'Engage\'s proprietary skin technology maximizes spin with a textured Fiberglass '
        'face. Excellent dinking control with solid baseline pop.',
    brand: 'Engage',
    weightOz: 7.8,
    gripSize: '4.375 in',
    faceMaterial: 'Fiberglass',
  ),
  Product(
    id: '6',
    name: 'Franklin Signature Carbon STK',
    price: 7279.00,
    imageUrl: 'assets/paddles/franklin_stk.jpg',
    description:
        'A raw Carbon Fiber face paddle offering exceptional spin and a lightweight feel. '
        'Designed for speed demons at the net.',
    brand: 'Franklin',
    weightOz: 7.2,
    gripSize: '4.125 in',
    faceMaterial: 'Carbon Fiber',
  ),
  Product(
    id: '7',
    name: 'HEAD Radical Pro',
    price: 7799.00,
    imageUrl: 'assets/paddles/head_radical.jpg',
    description:
        'A Graphite face paddle using HEAD\'s ErgoShape handle for a natural, comfortable grip. '
        'Balanced for all-court play.',
    brand: 'HEAD',
    weightOz: 8.0,
    gripSize: '4.25 in',
    faceMaterial: 'Graphite',
  ),
  Product(
    id: '8',
    name: 'ProKennex Kinetic Black Ace',
    price: 9999.00,
    imageUrl: 'assets/paddles/prokennex_black_ace.jpg',
    description:
        'Features Kinetic technology to reduce arm fatigue and vibration. Carbon Fiber face '
        'with a wide body for a forgiving sweet spot.',
    brand: 'ProKennex',
    weightOz: 8.3,
    gripSize: '4.25 in',
    faceMaterial: 'Carbon Fiber',
  ),
  Product(
    id: '9',
    name: 'Gamma Compass NeuCore',
    price: 5599.00,
    imageUrl: 'assets/paddles/gamma_compass.jpg',
    description:
        'A budget-friendly Fiberglass paddle with NeuCore foam filling for a soft, '
        'responsive feel. Perfect for beginners and recreational players.',
    brand: 'Gamma',
    weightOz: 7.4,
    gripSize: '4.375 in',
    faceMaterial: 'Fiberglass',
  ),
];
