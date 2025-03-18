import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'CartItem.dart';
import 'bottomnav.dart';
import 'cart.dart';
import 'cartprovider.dart';
import 'homepage.dart';
import 'package:uuid/uuid.dart';

class ItemPage extends StatefulWidget {
  final String name;
  final String price;
  final String image;
  final String categoryName;

  const ItemPage({
    required this.name,
    required this.price,
    required this.image,
    required this.categoryName,
    Key? key,
  }) : super(key: key);

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  int quantity = 1;
  final uuid = Uuid();

  void showTopSnackBar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 1), () {
      overlayEntry.remove();
    });
  }

  List<Map<String, dynamic>> getRelatedProducts() {
    return [
      {"name": "Related Product 1", "image": "assets/images/product1.png", "price": 10.0},
      {"name": "Related Product 2", "image": "assets/images/product2.png", "price": 15.0},
      {"name": "Related Product 3", "image": "assets/images/product3.png", "price": 20.0},
    ];
  }

  @override
  Widget build(BuildContext context) {
    double pricePerItem = double.tryParse(widget.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    double totalPrice = pricePerItem * quantity;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false,
        );
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green.shade700,
          elevation: 0,
          centerTitle: true,
          leading: Container(
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green[400],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                      (route) => false,
                );
              },
            ),
          ),
          title: Text(
            widget.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 8.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green[700],
              ),
              child: IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Cart(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 1, bottom: 0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
                Center(
                  child: ClipRRect(
                    child: Image.asset(
                      widget.image,
                      height: 200,
                    ),
                  ),
                ),
                Center(
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 10),
                            onPressed: () {
                              setState(() {
                                if (quantity > 1) {
                                  quantity--;
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Quantity cannot be less than 1'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              });
                            },
                          ),
                          Text(quantity.toString(), style: const TextStyle(color: Colors.black, fontSize: 10)),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 10),
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
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Price: ${widget.price}',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Category: ${widget.categoryName}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Weight',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const Text(
                            '1 kilogram per box',
                            style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Details',
                            style: TextStyle(color: Colors.black, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const Text(
                            'The description of the medicine',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )

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
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              'Total \₵${totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.black),
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
                          onTap: () {
                            String cleanedPrice = widget.price.replaceAll(RegExp(r'[^0-9.]'), '');
                            double parsedPrice = double.parse(cleanedPrice);

                            final newItem = CartItem(
                              id: uuid.v4(),
                              name: widget.name,
                              price: parsedPrice,
                              image: widget.image,
                              quantity: quantity,
                            );
                            context.read<CartProvider>().addToCart(newItem);
                            showTopSnackBar(context, 'Added to cart');
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: const Center(
                              child: Text(
                                'Add to Cart',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Related Products',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
      SizedBox(
        height: 150, // Reduce overall height
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: getRelatedProducts().length,
          itemBuilder: (context, index) {
            final product = getRelatedProducts()[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ItemPage(
                      name: product["name"],
                      price: product["price"].toString(),
                      image: product["image"],
                      categoryName: widget.categoryName,
                    ),
                  ),
                );
              },
              child: Container(
                width: 150, // Reduce container width
                margin: const EdgeInsets.only(right: 10),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 90,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.asset(
                            product["image"],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product["name"],
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'GHS ${product["price"]}',
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


    ],
            ),
          ),
        ),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
      ),
    );
  }
}