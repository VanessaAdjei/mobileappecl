

import 'package:eclapp/pages/profile.dart';
import 'package:eclapp/pages/storelocation.dart';
import 'package:flutter/material.dart';
import 'cart.dart';
import 'homepage.dart';
import 'itemdetail.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final List<String> categories = [
    'Prescription Medicines',
    'Over-the-Counter (OTC) Medicines',
    'Vitamins & Supplements',
    'Herbal Remedies',
    'Personal Care & Hygiene',
    'Medical Devices',
    'Baby Care Products',
    'Skin Care',
    'Health Drinks & Nutrition',
    'Diabetes Care',
    'Cardiovascular Health',
    'Pain Relief',
    'Allergy & Cold Remedies',
    'First Aid Supplies',
    'Eye Care',
    'Respiratory Care',
    'Women\'s Health',
    'Men\'s Health',
    'Orthopedic Supports',
    'Surgical Supplies',
  ];

  List<Map<String, String>> products = [
    {'name': 'Product 1', 'price': '100 GHS', 'image': 'assets/images/product1.png'},
    {'name': 'Product 2', 'price': '200 GHS', 'image': 'assets/images/product2.png'},
    {'name': 'Product 3', 'price': '150 GHS', 'image': 'assets/images/product3.png'},
    {'name': 'Product 4', 'price': '250 GHS', 'image': 'assets/images/product4.png'},
    {'name': 'Product 5', 'price': '180 GHS', 'image': 'assets/images/product2.png'},
    {'name': 'Product 6', 'price': '300 GHS', 'image': 'assets/images/product4.png'},
    {'name': 'Product 7', 'price': '120 GHS', 'image': 'assets/images/product1.png'},
    {'name': 'Product 8', 'price': '220 GHS', 'image': 'assets/images/product2.png'},
  ];

  int _selectedIndex = 0;
  int _selectedCategoryIndex = 0;
  String _searchText = '';

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      Navigator.pop(context);
      return Future.value(false);
    },
    child:  Scaffold(
    appBar: AppBar(
    backgroundColor: Colors.green.shade600,
      title: SizedBox(
        height: 75,
        width: 150,
        child: Image.asset('assets/images/png.png'),

      ),
    leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
    Navigator.pop(context);
    },
    ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Cart()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search products',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),

          Container(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedCategoryIndex == index;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => _onCategorySelected(index),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.grey[200] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? Border.all(color: Colors.green[700]!, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          categories[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.black : Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Category Description
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Explore a wide range of products in the ${categories[_selectedCategoryIndex]} category.',
              style: TextStyle(color: Colors.grey[700], fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ),
          // Grid of Products
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  if (_searchText.isEmpty ||
                      products[index]['name']!
                          .toLowerCase()
                          .contains(_searchText.toLowerCase())) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemPage(
                              name: products[index]['name']!,
                              price: products[index]['price']!,
                              image: products[index]['image']!,
                              categoryName: categories[_selectedCategoryIndex],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Image.asset(
                                    products[index]['image']!,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                products[index]['name']!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                products[index]['price']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
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
    ));
  }
}