
import 'package:eclapp/pages/categories.dart';
import 'package:eclapp/pages/signinpage.dart';
import 'package:flutter/material.dart';
import 'package:eclapp/pages/splashscreen.dart';
import 'package:eclapp/pages/homepage.dart';
import 'package:eclapp/pages/cart.dart';
import 'package:eclapp/pages/profile.dart';
import 'package:eclapp/pages/aboutus.dart';
import 'package:eclapp/pages/privacypolicy.dart';
import 'package:eclapp/pages/tandc.dart';
import 'package:eclapp/pages/settings.dart';
import 'package:provider/provider.dart';
import 'pages/notificationstate.dart';
import 'pages/cartprovider.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // // Perform async tasks before runApp
  // await AuthService.clearAllUsers();
  // await AuthService.signUp('Test 1',"test@example.com", "password123", '0000000000');
  // await AuthService.signIn("test@example.com", "password123");
  //
  // bool isValid = await AuthService.validateCurrentPassword("password123");
  // print("Is current password valid? $isValid");
  //
  // bool isChanged = await AuthService.updatePassword("newpassword123");
  // print("Password changed successfully? $isChanged");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  // Toggle the dark mode
  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ECL App',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
      ),
      initialRoute: '/splashscreen',
      routes: {
        '/splashscreen': (context) => SplashScreen(),
        '/': (context) => HomePage(),
        '/cart': (context) => const Cart(),
        '/categories': (context) => CategoryPage(),
        '/profile': (context) => const Profile(),
        '/aboutus': (context) => AboutUsScreen(),
        '/signin': (context) => SignInScreen(),
        '/privacypolicy': (context) => PrivacyPolicyScreen(),
        '/termsandconditions': (context) => TermsAndConditionsScreen(),
        '/settings': (context) => SettingsScreen(toggleDarkMode: _toggleDarkMode),
      },
    );
  }
}
