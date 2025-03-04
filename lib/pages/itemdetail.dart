import 'package:eclapp/pages/profile.dart';
import 'package:eclapp/pages/storelocation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'CartItem.dart';
import 'cart.dart';
import 'cartprovider.dart';
import 'categories.dart';
import 'categorylist.dart';
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
  int _selectedIndex = 0;
  final uuid = Uuid();


  void showTopSnackBar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50, // Adjust this value to change the position
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


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) =>  const Cart()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryPage()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (context) => StoreSelectionPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    double pricePerItem = double.tryParse(widget.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    double totalPrice = pricePerItem * quantity;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
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
                Navigator.pop(context);
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
              child:          IconButton(
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
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      widget.image,
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Center(
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 16),
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
                          Text(quantity.toString(), style: const TextStyle(color: Colors.black, fontSize: 16)),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 16),
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
                const SizedBox(height: 5),
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Price: ${widget.price}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Category: ${widget.categoryName}',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 10),
                        const Text('Weight', style: TextStyle(color: Colors.black, fontSize: 16)),
                        const Text('1 kilogram per box', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text('Details', style: TextStyle(color: Colors.black, fontSize: 16)),
                        const Text(
                          'The description of the medicine',
                          style: TextStyle(color: Colors.black, fontSize: 14),
                        ),
                      ],
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
                            border: Border.all(color: Colors.grey[300]!), // Consistent border color
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Center( // Center the text within the container
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
                        child: InkWell( // Use InkWell for tap events on the Material
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
                              border: Border.all(color: Colors.grey[300]!), // Consistent border color
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                            child: const Center( // Center the button text
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
                )
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.green.shade700,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          elevation: 8.0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(icon: Icon(Icons.location_city_sharp), label: 'Stores'),
          ],
        ),
      ),
    );
  }
}


