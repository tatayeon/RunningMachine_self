import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget{
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text("홈화면"),
      ),
    );
  }
}