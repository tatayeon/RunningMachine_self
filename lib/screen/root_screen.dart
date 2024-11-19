import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'running_screen.dart';
import 'calendar_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> with SingleTickerProviderStateMixin {
  TabController? tcontroller;
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    tcontroller = TabController(length: 3, vsync: this);
    tcontroller!.addListener(tabListener);
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: tcontroller,
        children: [
          HomeScreen(),
          RunningScreen(onRunningStateChange: handleRunningStateChange),
          CalendarScreen(),
        ],
      ),
      bottomNavigationBar: isRunning
          ? null
          : BottomNavigationBar(
        currentIndex: tcontroller!.index,
        onTap: (int index) {
          setState(() {
            tcontroller!.animateTo(index);
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run),
            label: '런닝',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
        ],
      ),
    );
  }
}
