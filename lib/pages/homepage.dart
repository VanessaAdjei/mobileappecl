import 'package:eclapp/pages/storelocation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'CartItem.dart';
import 'ProductModel.dart';
import 'auth_service.dart';
import 'bottomnav.dart';
import 'cartprovider.dart';
import 'clickableimage.dart';
import 'itemdetail.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool _isLoading = false;
  final RefreshController _refreshController = RefreshController();




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
      showTopSnackBar(context, 'Could not open WhatsApp. Please ensure it is installed.');
    }
  }


  Future<void> loadProducts() async {
    try {
      setState(() => _isLoading = true);
      List<Product> loadedProducts = await AuthService().fetchProducts();
      setState(() {
        products = loadedProducts;
        filteredProducts = loadedProducts;
      });
    } catch (e) {
      showTopSnackBar(context, 'Failed to load products');
    } finally {
      setState(() => _isLoading = false);
      _refreshController.refreshCompleted();
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


  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredProducts = List.from(products);
      });
      return;
    }

    setState(() {
      filteredProducts = products
          .where((product) => product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }


  @override
  void initState() {
    super.initState();
    loadProducts();
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
  void dispose() {
    searchController.dispose();
    super.dispose();
  }


  Widget _buildActionCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Card 1: Meet the Pharmacists
          Expanded(
            child: _buildActionCard(
              icon: Icons.people,
              title: "Meet Our Pharmacists",
              color: Colors.blue[600]!,
              onTap: () {
                // Add navigation logic
              },
            ),
          ),
          SizedBox(width: 12),

          // Card 2: Store Locator
          Expanded(
            child: _buildActionCard(
              icon: Icons.location_on,
              title: "Store Locator",
              color: Colors.green[600]!,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => StoreSelectionPage()),
                );
              },
            ),
          ),
          SizedBox(width: 12),

          // Card 3: Submit Prescription
          Expanded(
            child: _buildActionCard(
              icon: Icons.contact_support_rounded,
              title: "Contact Us",
              color: Colors.orange[600]!,
              onTap: () => _showContactOptions("+233504518047"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: BoxConstraints(
          minWidth: 90,
          maxWidth: 100,
          minHeight: 100,
        ),
        padding: const EdgeInsets.all(10), // Reduced padding
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8), // Smaller icon padding
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20), // Smaller icon
            ),
            const SizedBox(height: 6), // Reduced spacing
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 11, // Smaller font
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildPopularProducts() {
    List<Map<String, String>> popularProducts = [

      {'name': 'Product', 'image': 'assets/images/prod2.png'},
      {'name': 'Product', 'image': 'assets/images/prod3.png'},
      {'name': 'Product', 'image': 'assets/images/prod4.png'},
      {'name': 'Product', 'image': 'assets/images/prod2.png'},
      {'name': 'Product', 'image': 'assets/images/prod5.png'},
      {'name': 'Product', 'image': 'assets/images/prod4.png'},
      {'name': 'Product', 'image': 'assets/images/prod2.png'},
      {'name': 'Product', 'image': 'assets/images/prod5.png'},
      {'name': 'Product', 'image': 'assets/images/prod4.png'},


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
      'assets/images/ban1.png',
      'assets/images/ban2.png',
      'assets/images/ban1.png',
    ];

    PageController _pageController = PageController(viewportFraction: 0.85);

    Timer? _timer;

    @override
    void initState() {
      _timer = Timer.periodic(Duration(seconds: 8), (timer) {
        if (_pageController.hasClients) {
          int nextPage = (_pageController.page?.toInt() ?? 0) + 1;
          if (nextPage >= imageUrls.length) nextPage = 0;
          _pageController.animateToPage(
            nextPage,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }

    @override
    void dispose() {
      _timer?.cancel();
      _pageController.dispose();
      super.dispose();
    }

    return Container(
      height: 150,
      padding: EdgeInsets.symmetric(vertical: 10),
      child: PageView.builder(
        controller: _pageController,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageUrls[index],
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;


    double cardWidth = screenWidth * 0.45;
    double cardHeight = screenHeight * 0.38;

    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: EdgeInsets.all(screenWidth * 0.015),
      decoration: BoxDecoration(
        color: Colors.white,

      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemPage(urlName: product.urlName),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: cardHeight * 0.2,
              padding: EdgeInsets.all(1),
              child: ClipRRect(
                child: Image.network(
                  product.thumbnail,
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
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(Icons.broken_image, size: 40),
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),

                    // Price and add to cart button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${product.price} GHS',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          iconSize: screenWidth * 0.05,
                          icon: Icon(Icons.add_shopping_cart),
                          color: Colors.green,
                          onPressed: () {
                            final parsedPrice = double.tryParse(
                                product.price.toString()) ??
                                0.0;
                            context.read<CartProvider>().addToCart(
                              CartItem(
                                id: product.id.toString(),
                                name: product.name,
                                price: parsedPrice,
                                image: product.thumbnail,
                                quantity: 1,
                              ),
                            );
                            showTopSnackBar(context, 'Added to cart');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SmartRefresher(
            controller: _refreshController,
            onRefresh: loadProducts,
            header: CustomHeader(
              builder: (context, mode) {
                return SizedBox(
                  height: 60,
                  child: Center(
                    child: _isLoading
                        ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                    )
                        : Icon(Icons.arrow_downward, color: Colors.green[700]),
                  ),
                );
              },
            ),
            child: CustomScrollView(
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
                              fillColor: Colors.white30,
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
                              padding: const EdgeInsets.only(top: 60),
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
                SliverToBoxAdapter(
                  child: _buildActionCards(),
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
                    child: ClickableImageButton(),
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
          ),

          // Loading indicator overlay
          if (_isLoading)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }

}

