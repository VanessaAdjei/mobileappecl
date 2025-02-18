import 'package:eclapp/pages/storelocation.dart';
import 'package:flutter/material.dart';
import 'Cart.dart';
import 'CartItems.dart';
import 'categorylist.dart';
import 'homepage.dart';
import 'profile.dart';

class AddPaymentPage extends StatefulWidget {
  @override
  _AddPaymentPageState createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  int _selectedIndex = 0;
  String? _selectedPaymentMethod;
  String? _selectedMoMoProvider;
  List<Map<String, String>> _paymentMethods = [];
  final TextEditingController _momoNumberController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

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

  void _savePaymentMethod() {
    if (_selectedPaymentMethod == 'MoMo' && _selectedMoMoProvider != null && _momoNumberController.text.isNotEmpty) {
      _paymentMethods.add({
        'type': 'MoMo',
        'provider': _selectedMoMoProvider!,
        'number': _momoNumberController.text,
      });
    } else if (_selectedPaymentMethod == 'Card' &&
        _cardNumberController.text.isNotEmpty &&
        _expiryDateController.text.isNotEmpty &&
        _cvvController.text.isNotEmpty) {
      _paymentMethods.add({
        'type': 'Card',
        'number': _cardNumberController.text,
        'expiry': _expiryDateController.text,
        'cvv': _cvvController.text,
      });
    }
    setState(() => _clearForm());
  }

  void _clearForm() {
    _selectedPaymentMethod = null;
    _selectedMoMoProvider = null;
    _momoNumberController.clear();
    _cardNumberController.clear();
    _expiryDateController.clear();
    _cvvController.clear();
  }

  void _deletePaymentMethod(int index) => setState(() => _paymentMethods.removeAt(index));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: Image.asset('assets/images/png.png', height: 50),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Cart())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(child: Image.asset('assets/images/payment.png', height: 200)),
              SizedBox(height: 10),
              if (_paymentMethods.isNotEmpty) _buildSavedPaymentMethods(),
              _buildPaymentForm(),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: _savePaymentMethod,
                  child: Text('Save Payment Method'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSavedPaymentMethods() {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Payment Methods:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(), // Prevent conflict with parent scroll
            itemCount: _paymentMethods.length,
            itemBuilder: (context, index) {
              final method = _paymentMethods[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(method['type'] == 'MoMo' ? 'MoMo - ${method['provider']}' : 'Card - **** ${method['number']!.substring(method['number']!.length - 4)}'),
                  subtitle: Text(method['number']!),
                  trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deletePaymentMethod(index)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _buildPaymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add a Payment Method:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        _buildDropdown('Payment Method', _selectedPaymentMethod, ['MoMo', 'Card'],
                (value) => setState(() => _selectedPaymentMethod = value)),
        SizedBox(height: 10), // Space between dropdowns
        if (_selectedPaymentMethod == 'MoMo') ...[
          _buildDropdown('MoMo Provider', _selectedMoMoProvider, ['Telecel', 'MTN', 'AirtelTigo'],
                  (value) => setState(() => _selectedMoMoProvider = value)),
          SizedBox(height: 10),
          _buildTextField('MoMo Number', _momoNumberController, TextInputType.phone),
        ],
        if (_selectedPaymentMethod == 'Card') ...[
          _buildTextField('Card Number', _cardNumberController, TextInputType.number),
          SizedBox(height: 10),
          _buildTextField('Expiry Date (MM/YY)', _expiryDateController, TextInputType.datetime),
          SizedBox(height: 10),
          _buildTextField('CVV', _cvvController, TextInputType.number, obscureText: true),
        ],
      ],
    );
  }


  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      value: value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType type, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(controller: controller, decoration: InputDecoration(labelText: label, border: OutlineInputBorder()), keyboardType: type, obscureText: obscureText),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.green.shade700,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
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
      ],
    );
  }
}
