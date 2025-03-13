import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eclapp/pages/homepage.dart';
import 'package:eclapp/pages/signinpage.dart';
import 'bottomnav.dart';
import 'cartprovider.dart';


class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  String deliveryOption = 'Delivery';
  // double deliveryFee = 4.00;
  String? selectedRegion;
  String? selectedCity;
  String? selectedTown;
  double deliveryFee = 0.00;

  TextEditingController addressController = TextEditingController();
  // String? selectedRegion, selectedCity, selectedStore;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Map<String, Map<String, Map<String, double>>> locationFees = {
    'Greater Accra': {
      'Accra': {'Madina': 5.00, 'Osu': 6.50},
      'Tema': {'Community 1': 6.00, 'Community 2': 7.00},
    },
    'Ashanti': {
      'Kumasi': {'Adum': 4.50, 'Asokwa': 5.50, 'Ahodwo': 6.00},
      'Ejisu': {'Ejisu Town': 5.00, 'Besease': 5.50},
    },
    'Western': {
      'Takoradi': {'Market Circle': 4.00, 'Anaji': 5.00, 'Effia': 6.00},
    },
  };

  List<String> regions = ['Greater Accra', 'Ashanti', 'Western'];
  Map<String, List<String>> cities = {
    'Greater Accra': ['Accra', 'Tema'],
    'Ashanti': ['Kumasi'],
    'Western': ['Takoradi'],
  };

  Map<String, List<String>> towns = {
    'Accra': ['Madina', 'Osu'],
    'Tema': ['Community 1', 'Community 2'],
    'Kumasi': ['Adum', 'Asokwa'],
    'Takoradi': ['Market Circle', 'Anaji'],
  };

  List<String> pickupLocations = ['Madina Mall', 'Accra Mall', 'Kumasi City Mall', 'Takoradi Mall'];



  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    }
  }

  void _handleDeliveryOptionChange(String option) {
    setState(() {
      deliveryOption = option;
      if (option == 'Pickup') {
        selectedRegion = null;
        selectedCity = null;
        selectedTown = null;  // Ensure it's reset
        deliveryFee = 0.00;
      }
    });
  }





  void _handleCheckout(BuildContext context) async {
    if (context.read<CartProvider>().cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your cart is empty!")),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You need to sign in first.")),
      );

      bool? result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );

      if (result != true) return;
    }

    context.read<CartProvider>().purchaseItems();
    context.read<CartProvider>().clearCart();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return WillPopScope(
          onWillPop: () async {
            if (Navigator.canPop(context)) {
              return true;
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
                    (route) => false,
              );
              return false;
            }
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

              title: const Text(
                'Your Cart',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
              ),
            ),
            body: cart.cartItems.isEmpty
                ? const Center(
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
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        '\₵${item.price}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        if (item.quantity > 1) {
                                          context.read<CartProvider>().updateQuantity(index, item.quantity - 1);
                                        }
                                      },
                                    ),
                                    Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () => context.read<CartProvider>().updateQuantity(index, item.quantity + 1),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => context.read<CartProvider>().removeFromCart(index),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildCheckoutSection(cart),
              ],
            ),
            bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
          ),
        );
      },
    );
  }


  Widget _buildCheckoutSection(CartProvider cart) {
    List<String> pickupLocations = [
      'Madina Mall',
      'Accra Mall',
      'Kumasi City Mall',
      'Takoradi Mall',
    ];


    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Delivery:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              _buildRadioButton('Delivery'),
              _buildRadioButton('Pickup'),
            ],
          ),

          // **Delivery Address or Pickup Location**
          if (deliveryOption == 'Delivery') ...[
            _buildRegionDropdown(),
            _buildCityDropdown(),
            _buildTownDropdown(),
          ] else ...[
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Pickup Location'),
              value: selectedTown,
              items: pickupLocations.map((location) {
                return DropdownMenuItem(value: location, child: Text(location, style: const TextStyle(fontSize: 14)));
              }).toList(),
              onChanged: (value) => setState(() => selectedTown = value),
            ),
          ],

          const SizedBox(height: 5), // Reduced spacing

          // **Price Details**
          _buildPriceDetails(cart),

          const SizedBox(height: 10),

          // **Checkout Button**
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12), // Smaller button padding
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _handleCheckout(context),
              child: const Text('Checkout', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }




  Widget _buildRadioButton(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: deliveryOption,
          onChanged: (newValue) => _handleDeliveryOptionChange(newValue!),
        ),
        Text(value),
      ],
    );
  }


  Widget _buildAddressField() {
    return TextField(
      controller: addressController,
      decoration: InputDecoration(
        labelText: 'Enter your address',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }

  Widget _buildPriceDetails(CartProvider cart) {
    double subtotal = cart.calculateSubtotal();
    double total = subtotal + (deliveryOption == 'Delivery' ? deliveryFee : 0.00);

    return Column(
      children: [
        _buildPriceRow('Subtotal', subtotal),
        if (deliveryOption == 'Delivery' && selectedTown != null)
          _buildPriceRow('Delivery Fee', deliveryFee, color: Colors.grey.shade800),
        _buildPriceRow('Total', total, isBold: true, color: Colors.green.shade800),
      ],
    );
  }



  Widget _buildPriceRow(String label, double amount, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
        Text('\₵${amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
      ],
    );
  }

  Widget _buildRegionDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Select Region'),
      value: selectedRegion,
      items: regions.map((region) {
        return DropdownMenuItem(value: region, child: Text(region));
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedRegion = value;
          selectedCity = null;
          selectedTown = null;
        });
      },
    );
  }

  // CITY DROPDOWN (Changes based on Region)
  Widget _buildCityDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Select City'),
      value: selectedCity,
      items: (selectedRegion != null && cities.containsKey(selectedRegion))
          ? cities[selectedRegion]!.map((city) {
        return DropdownMenuItem(value: city, child: Text(city));
      }).toList()
          : [],
      onChanged: (value) {
        setState(() {
          selectedCity = value;
          selectedTown = null;
        });
      },
    );
  }


  Widget _buildTownDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: 'Select Town'),
      value: selectedTown,
      items: (selectedCity != null && towns.containsKey(selectedCity))
          ? towns[selectedCity]!.map((town) {
        return DropdownMenuItem(value: town, child: Text(town));
      }).toList()
          : [],
      onChanged: (value) {
        setState(() {
          selectedTown = value;
          if (selectedRegion != null && selectedCity != null && selectedTown != null) {
            deliveryFee = locationFees[selectedRegion]?[selectedCity]?[selectedTown] ?? 0.00;
          }
        });
      },

    );
  }





}
