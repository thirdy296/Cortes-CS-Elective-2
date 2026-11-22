class Category {
  const Category({required this.id, required this.name});

  final int id;
  final String name;

  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(id: (json['id'] as num).toInt(), name: json['name'] as String);
}
