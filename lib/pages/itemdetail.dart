import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'Cart.dart';
import 'CartItem.dart';
import 'bottomnav.dart';
import 'cartprovider.dart';
import 'package:html/parser.dart' show parse;

class ItemPage extends StatefulWidget {
  final String urlName;

  const ItemPage({Key? key, required this.urlName}) : super(key: key);

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  late Future<Map<String, dynamic>> _productFuture;
  int quantity = 1;
  final uuid = Uuid();
  bool isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _productFuture = fetchProductDetails(widget.urlName);
  }

  String _cleanHtml(String html) {
    try {
      final document = parse(html);
      return document.body?.text ?? html;
    } catch (e) {
      return html.replaceAll(RegExp(r'<[^>]*>'), ' ');
    }
  }

  Widget _buildDescriptionSection(String? description) {
    final cleanText = description != null
        ? _cleanHtml(description).trim()
        : 'No description available';

    if (cleanText.isEmpty) return _buildNoDescription();

    final isLong = cleanText.length > 100;
    final displayText = isDescriptionExpanded
        ? cleanText
        : isLong ? '${cleanText.substring(0, 100)}...' : cleanText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayText,
          style: _descriptionTextStyle(),
        ),
        if (isLong) _buildReadMoreButton(),
      ],
    );
  }

  Widget _buildReadMoreButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(40, 30),
        ),
        onPressed: () => setState(() => isDescriptionExpanded = !isDescriptionExpanded),
        child: Text(
          isDescriptionExpanded ? 'Read Less' : 'Read More',
          style: TextStyle(
            color: Colors.green.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }


  Widget _buildNoDescription() {
    return const Text(
      'No description available.',
      style: TextStyle(
        fontStyle: FontStyle.italic,
        fontSize: 13,
        color: Colors.grey,
      ),
    );
  }

  TextStyle _descriptionTextStyle() {
    return const TextStyle(
      fontSize: 13,
      color: Colors.black54,
      height: 1.4,
    );
  }

  Future<Map<String, dynamic>> fetchProductDetails(String urlName) async {
    try {
      final response = await http.get(
        Uri.parse('https://eclcommerce.ernestchemists.com.gh/api/product-details/$urlName'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('data')) {
          final productData = data['data']['product'] ?? {};
          final inventoryData = data['data']['inventory'] ?? {};

          String name = 'Unknown Product';
          if (inventoryData['url_name'] != null) {
            name = inventoryData['url_name']
                .toString()
                .replaceAll('-', ' ')
                .split(' ')
                .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
                .join(' ');
          }

          String thumbnail = '';
          if (productData['images'] != null && productData['images'].isNotEmpty) {
            thumbnail = productData['images'][0]['url'] ?? '';
          }

          double price = 0.0;
          if (inventoryData['price'] != null) {
            price = inventoryData['price'] is int
                ? inventoryData['price'].toDouble()
                : inventoryData['price'] is double
                ? inventoryData['price']
                : double.tryParse(inventoryData['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
          }

          String category = '';
          if (productData['categories'] != null && productData['categories'].isNotEmpty) {
            category = productData['categories'][0]['description'] ?? '';
          }

          return {
            'product': {
              'name': name,
              'description': productData['description'] ?? '',
              'images': productData['images'] ?? [],
              'categories': productData['categories'] ?? [],
            },
            'inventory': inventoryData,
            'thumbnail': thumbnail,
            'price': price,
            'category': category,
          };
        }
      }
      throw Exception('Failed to load product details');
    } catch (e) {
      print('Error fetching product details: $e');
      throw Exception('Could not load product: $e');
    }
  }

  List<Map<String, dynamic>> getRelatedProducts() {
    return [
      {
        "name": "Paracetamol 500mg Tablets",
        "price": 5.99,
        "image": "https://eclcommerce.ernestchemists.com.gh/storage/paracetamol.jpg",
        "urlName": "paracetamol-500mg-tablets"
      },
      {
        "name": "Ibuprofen 200mg Capsules",
        "price": 7.50,
        "image": "https://eclcommerce.ernestchemists.com.gh/storage/ibuprofen.jpg",
        "urlName": "ibuprofen-200mg-capsules"
      },
      {
        "name": "Vitamin C 1000mg Tablets",
        "price": 12.99,
        "image": "https://eclcommerce.ernestchemists.com.gh/storage/vitamin-c.jpg",
        "urlName": "vitamin-c-1000mg-tablets"
      },
    ];
  }




  void showTopSnackBar(BuildContext context, String message, {Duration? duration}) {
    final overlay = Overlay.of(context);

    late final OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green[900],
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration ?? const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green[400],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: FutureBuilder<Map<String, dynamic>>(
          future: _productFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final product = snapshot.data!['product'] ?? {};
              return Text(
                product['name'] ?? 'Product Details',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              );
            }
            return const Text('Loading...');
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green[700],
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Cart()),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No product data available'));
          }

          final productData = snapshot.data!;
          final product = productData['product'] ?? {};
          final thumbnail = productData['thumbnail'] ?? '';
          final price = productData['price'] ?? 0.0;
          final category = productData['category'] ?? '';
          final totalPrice = price * quantity;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 1, bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 200,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: thumbnail.isNotEmpty
                        ? Image.network(
                      thumbnail,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.medical_services, size: 80),
                          ),
                        );
                      },
                    )
                        : Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.medical_services, size: 80),
                      ),
                    ),
                  ),
                ),

                if (category.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    child: Chip(
                      label: Text(
                        category,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.green.shade700,
                    ),
                  ),

                Center(
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: Colors.black, size: 16),
                            onPressed: () {
                              setState(() {
                                if (quantity > 1) {
                                  quantity--;
                                } else {
                                  showTopSnackBar(context, 'Quantity cannot be less than 1');
                                }
                              });
                            },
                          ),
                          Text(quantity.toString(),
                              style: const TextStyle(color: Colors.black, fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.black, size: 16),
                            onPressed: () {
                              setState(() {
                                quantity++;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  product['name'] ?? 'No name available',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'GHS ${price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          Center(
                            child: Text(
                              'Product Details',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const Divider(height: 16, thickness: 1),
                          const SizedBox(height: 4),

                          _buildDescriptionSection(product['description']),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Center(
                            child: Text(
                              'Total: GHS ${totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            final newItem = CartItem(
                              id: uuid.v4(),
                              name: product['name'] ?? 'Unknown Product',
                              price: price,
                              image: thumbnail.isNotEmpty ? thumbnail : 'https://eclcommerce.ernestchemists.com.gh/storage/default-product.png',
                              quantity: quantity,
                            );
                            Provider.of<CartProvider>(context, listen: false)
                                .addToCart(newItem);
                            showTopSnackBar(context, 'Added to cart');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade700,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'Add to Cart',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Related Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: getRelatedProducts().length,
                    itemBuilder: (context, index) {
                      final relatedProduct = getRelatedProducts()[index];
                      return Container(
                        width: 150,
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemPage(
                                    urlName: relatedProduct['urlName'],
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(10)),
                                    child: relatedProduct['image'].startsWith('http')
                                        ? Image.network(
                                      relatedProduct['image'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.image_not_supported),
                                      ),
                                    )
                                        : Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.medical_services),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        relatedProduct['name'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'GHS ${(relatedProduct['price'] as num).toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }
}