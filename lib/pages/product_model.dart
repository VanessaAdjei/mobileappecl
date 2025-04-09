class ProductVariant {
  final int id;
  final Product product;
  final String price;
  final String urlName;

  ProductVariant({
    required this.id,
    required this.product,
    required this.price,
    required this.urlName,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'],
      product: Product.fromJson(json['product']),
      price: json['price'],
      urlName: json['url_name'],
    );
  }
}

class Product {
  final String name;
  final String description;
  final String thumbnail;

  Product({
    required this.name,
    required this.description,
    required this.thumbnail,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      description: json['description'],
      thumbnail: json['thumbnail'],
    );
  }
}
