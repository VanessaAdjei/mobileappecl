import 'package:eclapp/pages/categories.dart';
import 'package:eclapp/pages/storelocation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'CartItem.dart';
import 'bottomnav.dart';
import 'cart.dart';
import 'cartprovider.dart';
import 'clickableimage.dart';
import 'itemdetail.dart';
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


  void makePhoneCall(String phoneNumber) async {
    final Uri callUri = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      throw "Could not launch $callUri";
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
                  makePhoneCall(phoneNumber);
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

    // Remove after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
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
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: popularProducts.map((product) {
              return GestureDetector(
                onTap: () {
                  print("Tapped on ${product['name']}");
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipOval(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          product['image']!,
                          fit: BoxFit.contain,
                          height: 90, // Adjust height
                          width: 80,  // Adjust width
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
      'assets/images/banner1.png',
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
      padding: EdgeInsets.all(8),
      height: 200,
      // width: 150,
      child: PageView.builder(
        controller: _pageController,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              imageUrls[index],
              fit: BoxFit.fill,
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
      child: SizedBox(
        width: 180, // Adjust width
        height: 240, // Adjust height
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              product['image']!,
              height: 90,
              width: 300,
              fit: BoxFit.cover,
            ),
            Flexible(
              child: Text(
                product['name']!,
                style: TextStyle(
                  fontSize: 14, // Reduce font size
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  product['price']!,
                  style: const TextStyle(
                    fontSize: 12, // Reduce font size
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
                    showTopSnackBar(context, 'Added to cart');
                  },
                  icon: Icon(Icons.add_shopping_cart, color: Colors.green, size: 18.0),
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
      padding: const EdgeInsets.all(8), // Reduce padding here
      child: Wrap(
        spacing: 16, // Reduce spacing here
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
                backgroundColor: Colors.green.shade700,
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
                            padding: const EdgeInsets.only(top: 50),
                            child: SizedBox(
                              height: 110,
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
                  Container(
                    margin: EdgeInsets.only(right: 0.0),
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
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
                  childAspectRatio: 1.2,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1.0),
                  child: ClickableImageRow(),
                ),
              ),
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
                  childAspectRatio: 1.2,
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
                  childAspectRatio: 1.2,
                ),
              ),
            ],
          ),
          // Add the "Contact Us" button here
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(10),
                  ),
                  onPressed: () => _showContactOptions("+233504518047"),
                  child: Icon(Icons.phone, size: 30, color: Colors.black),
                ),
                SizedBox(height: 8), // Space between icon and text
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),

    );
  }

}