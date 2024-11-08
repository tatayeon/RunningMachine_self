import 'package:flutter/material.dart';

class RuningScreen extends StatelessWidget{
  const RuningScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text("러닝 화면"),
      ),
    );
  }
}