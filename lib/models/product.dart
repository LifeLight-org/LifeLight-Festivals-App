class Product {
  final String title;
  final int id;
  final int price;
  final String imageUrl;

  Product({
    required this.title,
    required this.id,
    required this.price,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      title: json['name'],
      id: json['id'],
      price: json['price'],
      imageUrl: json['image'],
    );
  }
}