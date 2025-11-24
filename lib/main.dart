import 'package:dashboard/pages/home_screen.dart';
import 'package:dashboard/pages/split_screen.dart';
import 'package:dashboard/widgets/mobilebuild.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation App',
      theme: ThemeData.light(),
      home: kIsWeb ? HomeScreen() : Mobilebuild(),
      // home: Mobilebuild(),
      debugShowCheckedModeBanner: false,
    );
  }
}
