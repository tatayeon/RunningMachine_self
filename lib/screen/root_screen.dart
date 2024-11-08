import 'package:flutter/material.dart';

import 'calendar_screen.dart';
import 'home_screen.dart';
import 'running_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> with SingleTickerProviderStateMixin{
  TabController? tcontroller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tcontroller = TabController(length: 3, vsync: this);
    tcontroller!.addListener(tabListener);
  }

  ///tabListener, dispose이거 리스너 달아주면 해줘야한다.
  void tabListener() {
    setState(() {});
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
        children: renderChildren(), ///-> 우리가 띄울 화면을 여기서 직접하는게 아니라 이렇게 뺀다.
      ),
      bottomNavigationBar: renderBottomNavigation(),
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
          icon: Icon(Icons.edgesensor_high_outlined),
          label: "홈",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.edgesensor_high_outlined),
          label: "런닝",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.edgesensor_high_outlined),
          label: "캘린더",
        ),
      ],
    );
  }

  List<Widget> renderChildren() {
    return [
      HomeScreen(

      ),
      RunningScreen(),
      CalendarScreen(

      ),
    ];
  }
}