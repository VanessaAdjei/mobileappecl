import 'package:eclapp/pages/profile.dart';
import 'package:eclapp/pages/storelocation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'Cart.dart';
import 'CartItem.dart';
import 'bottomnav.dart';
import 'cartprovider.dart';
import 'homepage.dart';
import 'itemdetail.dart';
import 'product_model.dart';

const Map<String, List<String>> categories = {
  "MEDICINES": ["Pain Relief", "Cold & Flu", "Vitamins"],
  "PERSONAL CARE": ["Hair Care", "Beauty & Skin Care", "Oral Care", "Perfumery & Cologne"],
  "MOTHER AND BABY": ["Baby Care", "Baby Health", "Feeding & Nursing"],
  "HOME CARE": ["Cleaning Supplies", "Laundry Essentials"],
  "SANITARY CARE": ["Sanitary Pads", "Toilet Paper"],
  "SPORTS NUTRITION": ["Protein Powders", "Energy Bars"],
  "SEXUAL HEALTH": ["Condoms", "Lubricants"],
  "FOOD AND DRINKS": ["Snacks", "Beverages"],
  "HEALTHCARE DEVICES": ["Thermometers", "Blood Pressure Monitors"],
};

const Map<String, String> categoryImages = {
  "MEDICINES": "assets/images/medicine.png",
  "PERSONAL CARE": "assets/images/personal.png",
  "MOTHER AND BABY": "assets/images/img.png",
  "HOME CARE": "assets/images/home.png",
  "SANITARY CARE": "assets/images/sanitary.png",
  "SPORTS NUTRITION": "assets/images/sports.png",
  "SEXUAL HEALTH": "assets/images/sexual.png",
  "FOOD AND DRINKS": "assets/images/food.png",
  "HEALTHCARE DEVICES": "assets/images/health.png",
};

final Map<String, List<Map<String, dynamic>>> products = {
  "Pain Relief": [
    {"name": "Paracetamol", "image": "assets/images/product1.png", "price": 10.0},
    {"name": "Ibuprofen", "image": "assets/images/product2.png", "price": 15.0},
    {"name": "Aspirin", "image": "assets/images/product3.png", "price": 12.0},
  ],
  "Cold & Flu": [
    {"name": "Cold Syrup", "image": "assets/images/product1.png", "price": 20.0},
    {"name": "Vicks Vaporub", "image": "assets/images/product2.png", "price": 25.0},
    {"name": "Nasal Spray", "image": "assets/images/product4.png", "price": 18.0},
  ],
  "Vitamins": [
    {"name": "Vitamin C", "image": "assets/images/product4.png", "price": 30.0},
    {"name": "Multivitamin", "image": "assets/images/product1.png", "price": 40.0},
    {"name": "Vitamin D", "image": "assets/images/product3.png", "price": 35.0},
  ],
  "Hair Care": [
    {"name": "Shampoo", "image": "assets/images/product1.png", "price": 25.0},
    {"name": "Conditioner", "image": "assets/images/product4.png", "price": 27.0},
    {"name": "Hair Oil", "image": "assets/images/product2.png", "price": 22.0},
  ],
  "Beauty & Skin Care": [
    {"name": "Moisturizer", "image": "assets/images/product4.png", "price": 45.0},
    {"name": "Sunscreen", "image": "assets/images/product2.png", "price": 50.0},
    {"name": "Face Wash", "image": "assets/images/product1.png", "price": 30.0},
  ],
  "Oral Care": [
    {"name": "Toothpaste", "image": "assets/images/product4.png", "price": 12.0},
    {"name": "Mouthwash", "image": "assets/images/product3.png", "price": 20.0},
    {"name": "Dental Floss", "image": "assets/images/product2.png", "price": 15.0},
  ],
  "Perfumery & Cologne": [
    {"name": "Perfume", "image": "assets/images/product4.png", "price": 80.0},
    {"name": "Deodorant", "image": "assets/images/product3.png", "price": 25.0},
    {"name": "Body Spray", "image": "assets/images/product1.png", "price": 30.0},
  ],
  "Snacks": [
    {"name": "Chips", "image": "assets/images/product2.png", "price": 15.0},
    {"name": "Cookies", "image": "assets/images/product3.png", "price": 18.0},
    {"name": "Nuts", "image": "assets/images/product1.png", "price": 20.0},
  ],
  "Beverages": [
    {"name": "Juice", "image": "assets/images/product4.png", "price": 10.0},
    {"name": "Soda", "image": "assets/images/product2.png", "price": 12.0},
    {"name": "Energy Drink", "image": "assets/images/product1.png", "price": 15.0},
  ],
  "Thermometers": [
    {"name": "Digital Thermometer", "image": "assets/images/product2.png", "price": 35.0},
    {"name": "Infrared Thermometer", "image": "assets/images/product1.png", "price": 60.0},
    {"name": "Ear Thermometer", "image": "assets/images/product4.png", "price": 50.0},
  ],
  "Blood Pressure Monitors": [
    {"name": "Arm Monitor", "image": "assets/images/product2.png", "price": 120.0},
    {"name": "Wrist Monitor", "image": "assets/images/product1.png", "price": 100.0},
    {"name": "Portable Monitor", "image": "assets/images/product3.png", "price": 140.0},
  ],
};

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {


  final List<Widget> _routes = [
    HomePage(),
    const Cart(),
    CategoryPage(),
    Profile(),
    StoreSelectionPage(),
  ];


  TextEditingController _searchController = TextEditingController();
  List<String> _filteredCategories = categories.keys.toList();
  void _searchProduct(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCategories = categories.keys.toList();
      });
      return;
    }

    if (query.length >= 3) {
      Set<String> matchedCategories = {};

      products.forEach((subcategory, productList) {
        for (var product in productList) {
          if (product['name'].toLowerCase().contains(query.toLowerCase())) {
            categories.forEach((category, subcategories) {
              if (subcategories.contains(subcategory)) {
                matchedCategories.add(category);
              }
            });
          }
        }
      });

      setState(() {
        _filteredCategories = matchedCategories.toList();
      });
    } else {

      setState(() {
        _filteredCategories = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return Future.value(true);
        },
        child:  Scaffold(
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
          'Categories',
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
            child:IconButton(
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

      backgroundColor: Colors.grey[100],

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _searchController,
                onChanged: _searchProduct,
                decoration: InputDecoration(
                  hintText: "Search Categories...",
                  prefixIcon: Icon(Icons.search, color: Colors.green.shade700),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),

                itemCount: _filteredCategories.length,
                itemBuilder: (context, index) {
                  String categoryName = _filteredCategories[index];
                  List<String> subcategories = categories[categoryName]!;

                  return CategoryGridItem(
                    categoryName: categoryName,
                    subcategories: subcategories,
                    imagePath: categoryImages[categoryName] ?? "",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubcategoryPage(
                            categoryName: categoryName,
                            subcategories: subcategories,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    ));
  }
}

class CategoryGridItem extends StatelessWidget {
  final String categoryName;
  final List<String> subcategories;
  final VoidCallback onTap;
  final String imagePath;

  const CategoryGridItem({
    required this.categoryName,
    required this.subcategories,
    required this.onTap,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 150,
              width: double.infinity,
              child: ClipRRect(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text(
                    subcategories.join(', '),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }
}


class SubcategoryPage extends StatefulWidget {
  final String categoryName;
  final List<String> subcategories;

  const SubcategoryPage({
    required this.categoryName,
    required this.subcategories,
  });

  @override
  _SubcategoryPageState createState() => _SubcategoryPageState();
}

class _SubcategoryPageState extends State<SubcategoryPage> {
  String? _selectedSubcategory;
  List<Map<String, dynamic>> _displayedProducts = [];


  String getProductImageUrl(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    return 'https://eclcommerce.ernestchemists.com.gh/storage/$imagePath';
  }
  @override
  void initState() {
    super.initState();

    _displayAllProducts();
  }


  void _displayAllProducts() {
    List<Map<String, dynamic>> allProducts = [];

    for (String subcategory in widget.subcategories) {
      if (products.containsKey(subcategory)) {
        allProducts.addAll(products[subcategory]!);
      }
    }

    setState(() {
      _displayedProducts = allProducts;
      _selectedSubcategory = null;
    });
  }

  void _filterProductsBySubcategory(String subcategory) {
    setState(() {
      _displayedProducts = products[subcategory] ?? [];
      _selectedSubcategory = subcategory;
    });
  }
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


    Future.delayed(const Duration(seconds: 2), () {
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
          widget.categoryName,
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
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.subcategories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return GestureDetector(
                    onTap: _displayAllProducts,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedSubcategory == null
                            ? Colors.green.shade700
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          "All",
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedSubcategory == null
                                ? Colors.white
                                : Colors.green.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                String subcategory = widget.subcategories[index - 1];
                return GestureDetector(
                  onTap: () => _filterProductsBySubcategory(subcategory),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedSubcategory == subcategory
                          ? Colors.green.shade700
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        subcategory,
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedSubcategory == subcategory
                              ? Colors.white
                              : Colors.green.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Product Grid
          Expanded(
            child: _displayedProducts.isEmpty
                ? Center(
              child: Text(
                "No products available",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(15.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 0,
                childAspectRatio: 0.93,
              ),

              itemCount: _displayedProducts.length,
              itemBuilder: (context, index) {
                final product = _displayedProducts[index];
                return GestureDetector(
                  // onTap: () {
                  //   Navigator.push(
                  //     context,
                  //       MaterialPageRoute(
                  //         ),
                  //       )
                  //   );
                  // },
                  child: Card(
                    elevation: 0,
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.asset(
                              product['image'], // Access image correctly
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],  // Access name correctly
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "GHS ${product['price']}", // Access price correctly
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      final newItem = CartItem(
                                        id: Uuid().v4(),
                                        name: product['name'], // Access name correctly
                                        price: product['price'], // Access price correctly
                                        image: product['image'], // Access image correctly
                                        quantity: 1,
                                      );
                                      context.read<CartProvider>().addToCart(newItem);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Added to cart"),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.add_shopping_cart,
                                      color: Colors.green,
                                      size: 18.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );

              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }
}
