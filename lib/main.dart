import 'package:flutter/material.dart';
import 'package:tflite_demo/homePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TFLite Demo',
      home: HomePage(),
    );
  }
}
