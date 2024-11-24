import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
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
              "로그아웃",
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () async {
              try {
                // Firebase 로그아웃
                await FirebaseAuth.instance.signOut();

                // 구글 로그아웃
                await GoogleSignIn().signOut();

                // 카카오톡 로그아웃
                await UserApi.instance.logout();

                // 로그아웃 성공 메시지
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("로그아웃 성공")),
                );
              } catch (e) {
                print("로그아웃 중 오류 발생: $e");

                // 오류 메시지 표시
                if (context.mounted) { // context가 유효한지 체크
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("로그아웃 실패: ${e.toString()}")),
                  );
                }
              }
            },
          )
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
