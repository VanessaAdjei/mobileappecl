import 'package:eclapp/pages/homepage.dart';
import 'package:eclapp/pages/profile.dart';
import 'package:eclapp/pages/signinpage.dart';
import 'package:eclapp/pages/storelocation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'bottomnav.dart';
import 'cartprovider.dart';
import 'categories.dart';

class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  _CartState createState() => _CartState();
}



class _CartState extends State<Cart> {
  String deliveryOption = 'Delivery';
  double deliveryFee = 4.00;

  List<String> regions = ['Region 1', 'Region 2', 'Region 3'];
  List<String> cities = ['City 1', 'City 2', 'City 3'];
  List<String> stores = ['Store 1', 'Store 2', 'Store 3'];

  TextEditingController addressController = TextEditingController();

  String? selectedRegion;
  String? selectedCity;
  String? selectedStore;

  @override
  void initState() {
    super.initState();
    // _checkLoginStatus();
  }
  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    }
  }


  void onHandleCheckout(BuildContext context) {
    if (context.read<CartProvider>().cartItems.isNotEmpty) {
      context.read<CartProvider>().purchaseItems();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Your cart is empty!")),
      );
    }
  }

  int _selectedIndex = 1;

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

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child)
    {
      return WillPopScope(
          onWillPop: () async {
            Navigator.pop(HomePage() as BuildContext);
            return false;
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
                'Your Cart',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              actions: [
                // Container(
                //   margin: EdgeInsets.only(right: 8.0),
                //   decoration: BoxDecoration(
                //     shape: BoxShape.circle,
                //     color: Colors.green[700],
                //
                //   ),
                //   child:          IconButton(
                //     icon: Icon(Icons.shopping_cart, color: Colors.white),
                //     onPressed: () {
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => const Cart(),
                //         ),
                //       );
                //     },
                //   ),
                // ),
              ],
            ),
              body: cart.cartItems.isEmpty
                  ? Center(
                child: Text(
                  'Your cart is empty',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
                  : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cart.cartItems[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      item.image,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        Text(
                                          '\₵${item.price}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove),
                                        onPressed: () {
                                          setState(() {
                                            if (item.quantity > 1) {
                                              context
                                                  .read<CartProvider>()
                                                  .updateQuantity(
                                                  index, item.quantity - 1);
                                            }
                                          });
                                        },
                                      ),
                                      Text(
                                        '${item.quantity}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: () {
                                          setState(() {
                                            item.quantity++;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        context
                                            .read<CartProvider>()
                                            .removeFromCart(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 8,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Delivery or Pickup Option
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Delivery Option: ',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(width: 8),
                            Row(
                              children: [
                                Radio<String>(
                                  value: 'Delivery',
                                  groupValue: deliveryOption,
                                  onChanged: (value) {
                                    setState(() {
                                      deliveryOption = value!;
                                    });
                                  },
                                ),
                                Text('Delivery'),
                                SizedBox(width: 10),
                                Radio<String>(
                                  value: 'Pickup',
                                  groupValue: deliveryOption,
                                  onChanged: (value) {
                                    setState(() {
                                      deliveryOption = value!;
                                      selectedRegion = null;
                                      selectedCity = null;
                                      selectedStore = null;
                                    });
                                  },
                                ),
                                Text('Pickup'),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        if (deliveryOption == 'Delivery') ...[
                          TextField(
                            controller: addressController,
                            decoration: InputDecoration(
                              labelText: 'Enter your address',
                              labelStyle: TextStyle(
                                  color: Colors.grey.shade600),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: Colors.grey.shade400),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.green),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                            ),
                          ),
                        ],
                        SizedBox(height: 20),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                Text(
                                  'Subtotal',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '\₵${cart.calculateSubtotal()
                                      .toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade800),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            if (deliveryOption == 'Delivery') ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Text(
                                    'Delivery Fee',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '\₵${deliveryFee.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade800),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                                Text(
                                  '\₵${cart.calculateTotal().toStringAsFixed(
                                      2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                            onPressed: () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isLoggedIn) {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("You need to sign in first.")),
    );
    bool? result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SignInScreen()),
    );

    if (result == true) {
    context.read<CartProvider>().purchaseItems();
    context.read<CartProvider>().clearCart();
    }
    } else {
    context.read<CartProvider>().purchaseItems();
    context.read<CartProvider>().clearCart();
    }
    }
    ,
      child: Text(
                            'Checkout',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
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
          )
      );});}}

