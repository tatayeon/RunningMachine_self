import 'package:flutter/material.dart';
import 'package:smop_final/screen/root_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Firebase 초기화 전에 반드시 호출해야 합니다.
  await Firebase.initializeApp();  // Firebase 초기화
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RootScreen(),
    ),
  );
}
