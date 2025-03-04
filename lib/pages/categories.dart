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

      backgroundColor: Colors.grey[100],

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),

            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,  // Display two cards per row
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1, // Adjust card height if needed
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  String categoryName = categories.keys.elementAt(index);
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
    );
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
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                categoryName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
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
  List<Map<String, dynamic>> _displayedProducts = []; // Correct type

  @override
  void initState() {
    super.initState();
    // Display all products under the selected category by default
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
      body: Column(
        children: [
          // Scrollable Subcategory Bar
          Container(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.subcategories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // "All" option
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
                  color: Colors.grey.shade600,
                ),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 items per row
                crossAxisSpacing: 16, // Horizontal space between items
                mainAxisSpacing: 16, // Vertical space between items
                childAspectRatio: 0.8, // Adjust the aspect ratio for better layout
              ),
              itemCount: _displayedProducts.length,
              itemBuilder: (context, index) {
                final product = _displayedProducts[index];
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
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.asset(
                              product["image"],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product["name"],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "GHS ${product["price"]}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      // Add to cart logic
                                      final newItem = CartItem(
                                        id: Uuid().v4(), // Generate unique ID
                                        name: product["name"],
                                        price: product["price"],
                                        image: product["image"],
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
