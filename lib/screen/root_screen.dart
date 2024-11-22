import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smop_final/screen/calendar_screen.dart';
import 'package:smop_final/screen/running_screen.dart';

import 'home_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RootScreenState();

}


class _RootScreenState extends State<RootScreen> with SingleTickerProviderStateMixin {
  TabController? tcontroller;
  bool isRunning = false;

  bool showBottomNav = true; // Bottom Navigation Bar visibility

  @override
  void initState() {
    super.initState();
    tcontroller = TabController(length: 3, vsync: this);
    tcontroller!.addListener(tabListener);
  }

  /// tabListener와 dispose
  void tabListener() {
    setState(() {});
  }
  void handleRunningStateChange(bool running) {
    setState(() {
      isRunning = running;
    });
  }


  @override
  void dispose() {
    tcontroller!.removeListener(tabListener);
    super.dispose();
  }

  void toggleBottomNav(bool isVisible) {
    setState(() {
      showBottomNav = isVisible; // Update the visibility of Bottom Navigation Bar
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            child: Text(
              "Google logOut",
              style: TextStyle(color: Colors.black),
            ),
            onPressed: FirebaseAuth.instance.signOut,
          ),
        ],

      ),
      body: TabBarView(

        controller: tcontroller,
        children: renderChildren(),
      ),
      bottomNavigationBar: showBottomNav
          ? renderBottomNavigation() // Show Bottom Navigation Bar only when visible
          : SizedBox.shrink(),
    );
  }

  BottomNavigationBar renderBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: tcontroller!.index,
      onTap: (int index) {
        setState(() {
          tcontroller!.animateTo(index);
        });
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "홈",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_run),
          label: "런닝",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "캘린더",
        ),
      ],
    );
  }

  List<Widget> renderChildren() {
    return [
      HomeScreen(
        onToggleBottomNav: toggleBottomNav, // Pass callback to HomeScreen
      ),
      RunningScreen(onRunningStateChange: handleRunningStateChange),
      CalendarScreen(),
    ];
  }
}
