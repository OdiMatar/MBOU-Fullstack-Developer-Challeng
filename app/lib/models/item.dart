class Item {
  final int id;
  final String name;
  final String description;
  final String? brand;
  final double? price;
  final int? stock;
  final String? imageUrl;
  final String? color;

  Item({
    required this.id,
    required this.name,
    required this.description,
    this.brand,
    this.price,
    this.stock,
    this.imageUrl,
    this.color,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      brand: json['brand'],
      price: json['price'] != null ? double.parse(json['price'].toString()) : null,
      stock: json['stock'],
      imageUrl: json['image_url'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'brand': brand,
      'price': price,
      'stock': stock,
      'image_url': imageUrl,
      'color': color,
    };
  }
}
