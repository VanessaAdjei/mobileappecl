import 'package:eclapp/pages/storelocation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'CartItem.dart';
import 'cart.dart';
import 'cartprovider.dart';
import 'itemdetail.dart';
import 'categorylist.dart';
import 'profile.dart';
import 'dart:async';

class HomePage extends StatefulWidget {


  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> products = [
    {'name': 'Product 1', 'price': '100 GHS', 'image': 'assets/images/product1.png'},
    {'name': 'Product 2', 'price': '200 GHS', 'image': 'assets/images/product2.png'},
    {'name': 'Product 3', 'price': '150 GHS', 'image': 'assets/images/product3.png'},
    {'name': 'Product 4', 'price': '250 GHS', 'image': 'assets/images/product4.png'},
    {'name': 'Product 5', 'price': '100 GHS', 'image': 'assets/images/product1.png'},
    {'name': 'Product 6', 'price': '200 GHS', 'image': 'assets/images/product1.png'},
    {'name': 'Product 7', 'price': '150 GHS', 'image': 'assets/images/product2.png'},
    {'name': 'Product 8', 'price': '250 GHS', 'image': 'assets/images/product3.png'},
    {'name': 'Product 9', 'price': '100 GHS', 'image': 'assets/images/product4.png'},
    {'name': 'Product 10', 'price': '200 GHS', 'image': 'assets/images/product4.png'},
    {'name': 'Product 11', 'price': '150 GHS', 'image': 'assets/images/product4.png'},
    {'name': 'Product 12', 'price': '250 GHS', 'image': 'assets/images/product2.png'},
    {'name': 'Product 13', 'price': '100 GHS', 'image': 'assets/images/product1.png'},
    {'name': 'Product 14', 'price': '200 GHS', 'image': 'assets/images/product4.png'},
    {'name': 'Product 15', 'price': '150 GHS', 'image': 'assets/images/product1.png'},
    {'name': 'Product 16', 'price': '250 GHS', 'image': 'assets/images/product1.png'},
    {'name': 'Product 17', 'price': '100 GHS', 'image': 'assets/images/product1.png'},
    {'name': 'Product 18', 'price': '200 GHS', 'image': 'assets/images/product2.png'},
    {'name': 'Product 19', 'price': '150 GHS', 'image': 'assets/images/product4.png'},
    {'name': 'Product 20', 'price': '250 GHS', 'image': 'assets/images/product3.png'},
  ];

  List<Map<String, String>> filteredProducts = [];
  TextEditingController searchController = TextEditingController();

  ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  _launchPhoneDialer(String phoneNumber) async {
    final permissionStatus = await Permission.phone.request();
    if (permissionStatus.isGranted) {
      final String formattedPhoneNumber = 'tel:$phoneNumber';
      print("Dialing number: $formattedPhoneNumber");
      if (await canLaunch(formattedPhoneNumber)) {
        await launch(formattedPhoneNumber);
      } else {
        print("Error: Could not open the dialer.");
      }
    } else {
      print("Permission denied.");
    }
  }


  _launchWhatsApp(String phoneNumber, String message) async {
    if (phoneNumber.isEmpty || message.isEmpty) {
      print("Phone number or message is empty");
      return;
    }

    if (!phoneNumber.startsWith('+')) {
      print("Phone number must include the country code (e.g., +233504518047)");
      return;
    }

    String whatsappUrl = 'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}';

    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      print("WhatsApp is not installed or cannot be launched.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open WhatsApp. Please ensure it is installed.')),
      );
    }
  }

  void _showContactOptions(String phoneNumber) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.call, color: Colors.green),
                title: Text('Call'),
                onTap: () {
                  Navigator.pop(context);
                  _launchPhoneDialer(phoneNumber);
                },
              ),
              ListTile(
                leading: Icon(Icons.call_end_rounded, color: Colors.green),
                title: Text('WhatsApp'),
                onTap: () {
                  Navigator.pop(context);
                  _launchWhatsApp(phoneNumber, "Hello, I'm interested in your products!");
                },
              ),
            ],
          ),
        );
      },
    );
  }




  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Cart()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => CategoriesPage()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => Profile()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (context) => StoreSelectionPage()));
        break;
    }
  }


  void _filterProducts(String query) {
    setState(() {
      filteredProducts = products
          .where((product) => product['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    filteredProducts = products;
    searchController.addListener(() {
      _filterProducts(searchController.text);
    });
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_isScrolled) {
        setState(() {
          _isScrolled = true;
        });
      } else if (_scrollController.offset <= 100 && _isScrolled) {
        setState(() {
          _isScrolled = false;
        });
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Widget _buildPopularProducts() {
    List<Map<String, String>> popularProducts = [
      {'name': 'Product', 'image': 'assets/images/popular4.png'},
      {'name': 'Product', 'image': 'assets/images/popular2.png'},
      {'name': 'Product', 'image': 'assets/images/popular3.png'},
      {'name': 'Product', 'image': 'assets/images/popular4.png'},
      {'name': 'Product', 'image': 'assets/images/popular2.png'},

    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(
            'Popular Products',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: popularProducts.map((product) {
              return GestureDetector(
                onTap: () {
                  print("Tapped on ${product['name']}");
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: ClipOval(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          product['image']!,
                          fit: BoxFit.contain,
                          height: 100,
                          width: 100,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Divider(
          color: Colors.grey.shade300,
          thickness: 2.0,
        ),
      ],
    );
  }

  Widget _buildOrderMedicineCard() {
    List<String> imageUrls = [
      'assets/images/slider1.png',
      'assets/images/slider2.png',
      'assets/images/slider3.png',
    ];

    PageController _pageController = PageController();

    Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_pageController.page?.toInt() ?? 0) + 1;
        if (nextPage >= imageUrls.length) nextPage = 0;
        _pageController.animateToPage(nextPage, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
      }
    });

    return Container(
      padding: EdgeInsets.all(16),
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              imageUrls[index],
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Map<String, String> product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemPage(
              name: product['name']!,
              price: product['price']!,
              image: product['image']!,
              categoryName: 'All Categories',
            ),
          ),
        );
      },
      child: Container(
        width: 10,
        padding: const EdgeInsets.all(0),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              product['image']!,
              height: 130,
              width: 350,
              fit: BoxFit.fitWidth,
            ),
            const SizedBox(height: 1),
            Text(
              product['name']!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product['price']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    String cleanedPrice = product['price']!.replaceAll(RegExp(r'[^0-9.]'), '');
                    double parsedPrice = double.parse(cleanedPrice);

                    final newItem = CartItem(
                      id: const Uuid().v4(),
                      name: product['name']!,
                      price: parsedPrice,
                      image: product['image']!,
                      quantity: 1,
                    );

                    context.read<CartProvider>().addToCart(newItem);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to cart')),
                    );
                  },
                  icon: Icon(Icons.add_shopping_cart, color: Colors.green, size: 20.0),

                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildContactRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Wrap(
        spacing: 60,
        alignment: WrapAlignment.center,
        children: [

          _buildContactItem(
            context,
            icon: Icon(Icons.location_on),
            label: 'Store Locations',
            phoneNumber: '',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StoreSelectionPage()),
              );

            },
          ),

          // Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     ElevatedButton(
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.green,
          //         shape: CircleBorder(),
          //         padding: EdgeInsets.all(10),
          //       ),
          //       onPressed: () => _showContactOptions("+233504518047"),
          //       child: Icon(Icons.phone, size: 30, color: Colors.black),
          //     ),
          //     SizedBox(height: 8),
          //     Text(
          //       "Contact Us",
          //       style: TextStyle(color: Colors.black),
          //     ),
          //   ],
          // )

        ],
      ),
    );
  }

  Widget _buildContactItem(
      BuildContext context, {
        required Widget icon,
        required String label,
        required VoidCallback onTap,
        required String phoneNumber,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: label,
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.green.shade200, Colors.green.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: Offset(2, 3),
                  ),
                ],
              ),
              child: icon,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 50.0,
                floating: false,
                automaticallyImplyLeading: false,
                pinned: true,
                backgroundColor: Colors.green.shade600,
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    return FlexibleSpaceBar(
                      centerTitle: false,
                      titlePadding: EdgeInsets.only(left: 16, bottom: 10),
                      title: _isScrolled
                          ? SizedBox(
                        height: 40,
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                            prefixIcon: Icon(Icons.search, color: Colors.black),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: SizedBox(
                              height: 75,
                              width: 100,
                              child: Image.asset(
                                'assets/images/png.png',
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                actions: [
                  IconButton(
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
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildOrderMedicineCard(),
              ),
              SliverGrid(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    if (index < 4) {
                      return _buildProductCard(filteredProducts[index]);
                    }
                    return SizedBox.shrink();
                  },
                  childCount: filteredProducts.length > 4 ? 4 : filteredProducts.length,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: 0.95,
                ),
              ),
              // SliverToBoxAdapter(
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(vertical: 1.0),
              //     child: _buildContactRow(context),
              //   ),
              // ),
              SliverGrid(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    int adjustedIndex = index + 4;
                    if (adjustedIndex < 8 && adjustedIndex < filteredProducts.length) {
                      return _buildProductCard(filteredProducts[adjustedIndex]);
                    }
                    return SizedBox.shrink();
                  },
                  childCount: filteredProducts.length > 8 ? 4 : (filteredProducts.length > 4 ? filteredProducts.length - 4 : 0),
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: 0.95,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 1.0),
                  child: _buildPopularProducts(),
                ),
              ),
              SliverGrid(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    int adjustedIndex = index + 8;
                    if (adjustedIndex < filteredProducts.length) {
                      return _buildProductCard(filteredProducts[adjustedIndex]);
                    }
                    return SizedBox.shrink();
                  },
                  childCount: filteredProducts.length > 8 ? filteredProducts.length - 8 : 0,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: 0.95,
                ),
              ),
            ],
          ),
          // Add the "Contact Us" button here
          Positioned(
            bottom: 20, // Adjust the position as needed
            right: 20, // Adjust the position as needed
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(10), // Adjust padding for the circle size
                  ),
                  onPressed: () => _showContactOptions("+233504518047"),
                  child: Icon(Icons.phone, size: 30, color: Colors.black),
                ),
                SizedBox(height: 8), // Space between icon and text
                Text(
                  "Contact Us",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.green.shade700,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        elevation: 8.0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_city_sharp),
            label: 'Stores',
          ),
        ],
      ),
    );
  }

}