import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:smop_final/screen/root_screen.dart';

import 'auth_home.dart';

class Auth extends StatelessWidget{
  const Auth({Key? key}) : super(key: key);

  Future<void> initializeApp() async{
    await Firebase.initializeApp(); //파이어 베이스 초기화
    KakaoSdk.init( //카카오톡 초기화
      nativeAppKey: "ab81cdf2604dc76d44dd51e9d1d4467c",//카카오톡 네이티브키
      javaScriptAppKey: "53c2bb71500fe4145109a1852cf2aef2",
    );
  }
  @override
  Widget build(BuildContext context){
    return FutureBuilder(future: initializeApp(),
      builder:(context,snapshot){
        if(snapshot.hasError){
          return Center(
            child: Text("error"),
          );
        }
        if(snapshot.connectionState==ConnectionState.done){
          return Authhome();
          }
        return CircularProgressIndicator();
        }

    );
  }
}