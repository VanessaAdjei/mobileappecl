import 'package:eclapp/pages/itemdetail.dart';
import 'package:eclapp/pages/storelocation.dart';
import 'package:flutter/material.dart';
import 'cart.dart';
import 'categorylist.dart';
import 'homepage.dart';
import 'profile.dart';


class CategoryPage extends StatefulWidget {
  final String name;
  final String price;
  final String image;
  final String categoryName;


  CategoryPage({
    required this.name,
    required this.price,
    required this.image,
  required this.categoryName
  });

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Map<String, String>> products = [
    {'name': 'Product 1', 'price': '100 GHS', 'image': 'assets/images/product.png'},
    {'name': 'Product 2', 'price': '200 GHS', 'image': 'assets/images/product.png'},
    {'name': 'Product 3', 'price': '150 GHS', 'image': 'assets/images/product.png'},
    {'name': 'Product 4', 'price': '250 GHS', 'image': 'assets/images/product.png'},
    {'name': 'Product 5', 'price': '180 GHS', 'image': 'assets/images/product.png'},
    {'name': 'Product 6', 'price': '300 GHS', 'image': 'assets/images/product.png'},
    {'name': 'Product 7', 'price': '120 GHS', 'image': 'assets/images/product.png'},
    {'name': 'Product 8', 'price': '220 GHS', 'image': 'assets/images/product.png'},
  ];

  String sortBy = 'Sort By Price';
  bool isDescending = true;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: Image.asset('assets/images/png.png', height: 50),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>const Cart()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Description or Tagline
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 20.0),
                child: Text(
                  'Explore a wide range of products in the ${widget.categoryName} category',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSortDropdown(),
                ],
              ),
              SizedBox(height: 20),
              // Grid of Products
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return _buildProductCard(products[index]);
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSortDropdown() {
    return DropdownButton<String>(
      value: sortBy,
      icon: Icon(Icons.arrow_downward, color: Colors.green.shade700),
      onChanged: (String? newValue) {
        setState(() {
          sortBy = newValue!;
          _sortProducts();
        });
      },
      items: <String>['Sort By Price', 'Sort By Name']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(color: Colors.green.shade700),
          ),
        );
      }).toList(),
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
              categoryName: widget.categoryName,
            ),
          ),
        );
      },
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Center(
                  child: Image.asset(
                    product['image']!,
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                product['name']!,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                product['price']!,
                style: TextStyle(fontSize: 14, color: Colors.green.shade700),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {},
                child: Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _sortProducts() {
    if (sortBy == 'Sort By Price') {
      products.sort((a, b) {
        int priceA = int.parse(a['price']!.split(' ')[0]);
        int priceB = int.parse(b['price']!.split(' ')[0]);
        return isDescending ? priceB.compareTo(priceA) : priceA.compareTo(priceB);
      });
    } else if (sortBy == 'Sort By Name') {
      products.sort((a, b) => a['name']!.compareTo(b['name']!));
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade600, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        showUnselectedLabels: true,
      ),
    );
  }
}
