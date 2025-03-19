import 'package:flutter/material.dart';
import 'wishlist.dart';  // Ensure this matches your file name

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WishlistScreen(),
    );
  }
}