// import 'package:flutter/material.dart';
// import 'package:eclapp/pages/profile.dart';
// import 'package:eclapp/pages/storelocation.dart';
// import 'Cart.dart';
// import 'categories.dart';
// import 'homepage.dart';
//
// class BottomNavigationPage extends StatefulWidget {
//   @override
//   _BottomNavigationPageState createState() => _BottomNavigationPageState();
// }
//
// class _BottomNavigationPageState extends State<BottomNavigationPage> {
//   int _selectedIndex = 0;
//
//   final List<Widget> _pages = [
//     HomePage(),
//     Cart(),
//     CategoryPage(),
//     Profile(),
//     StoreSelectionPage(),
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IndexedStack(
//         index: _selectedIndex,
//         children: _pages,
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: Colors.green.shade700,
//         selectedItemColor: Colors.white,
//         unselectedItemColor: Colors.white70,
//         elevation: 8.0,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_cart),
//             label: 'Cart',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.category),
//             label: 'Categories',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.location_city_sharp),
//             label: 'Stores',
//           ),
//         ],
//       ),
//     );
//   }
// }
