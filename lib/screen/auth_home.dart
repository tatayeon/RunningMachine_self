import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smop_final/screen/auth_scrren.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smop_final/screen/root_screen.dart';

import 'login.dart';


class Authhome extends StatelessWidget{
  const Authhome({Key? key}) : super (key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(

      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context,AsyncSnapshot<User?>snapshot){
          if(!snapshot.hasData){
            return LoginWidget();
          }else{
            return RootScreen();
          }
        },
      ),
    );
  }
}








