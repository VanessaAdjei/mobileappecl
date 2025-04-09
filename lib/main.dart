import 'package:eclapp/pages/auth_service.dart';
import 'package:eclapp/pages/categories.dart';
import 'package:eclapp/pages/product_model.dart';
import 'package:eclapp/pages/product_provider.dart';
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
import 'pages/cartprovider.dart';
import 'pages/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final Future<List<Object>> productsFuture = AuthService().getAllProducts();


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ECL App',
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

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
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
