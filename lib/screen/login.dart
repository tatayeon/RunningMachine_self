import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';


class LoginWidget extends StatelessWidget {
  const LoginWidget({Key? key}) : super(key: key);

  // 구글 로그인 구현
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Sign out any existing user to prevent auto-login
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // If the user cancels the sign-in process
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
      await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Sign in to Firebase with the generated credentials
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print("Error during Google Sign-In: $e");
      return null;
    }
  }

  // 카카오 로그인 버튼 눌렀을 때 실행되는 함수
  void onKakaoLoginPress(BuildContext context) async {
    try {
      var provider = OAuthProvider("oidc.runningmachine");
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      var credential = provider.credential(
        idToken: token.idToken,
        accessToken: token.accessToken,
      );

      // Firebase 로그인
      await FirebaseAuth.instance.signInWithCredential(credential);

      // 카카오 로그인 성공 여부 확인
      bool loginSuccess = await signWithKakao();
      if (!loginSuccess) {
        throw Exception('Kakao login failed.');
      }

      // 로그인 성공 후, Snackbar로 로그인 성공 메시지 표시
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카카오 로그인 성공')),
        );
      });
    } catch (error) {
      // 로그인 실패 시 Snackbar로 오류 메시지 표시
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카카오 로그인 실패')),
        );
      });
    }
  }
  // 카카오 로그인 구현
  Future<bool> signWithKakao() async {
    try {
      // 카카오톡 설치 여부 확인
      if (await isKakaoTalkInstalled()) {
        try {
          await UserApi.instance.loginWithKakaoTalk();
          print('카카오톡으로 로그인 성공');
          return true;
        } catch (error) {
          print('카카오톡으로 로그인 실패 $error');
          if (error is PlatformException && error.code == 'CANCELED') {
            return false;
          }
        }
      }

      // 카카오톡 설치 안 되어 있거나 실패 시 카카오 계정으로 로그인
      await UserApi.instance.loginWithKakaoAccount();
      print('카카오 계정으로 로그인 성공');
      return true;
    } catch (error) {
      print('카카오 계정으로 로그인 실패 $error');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/img/home.jpg', // Replace with your asset image path
              fit: BoxFit.cover,
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Runner Away',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                // 구글 로그인 버튼
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // 배경색
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () async {
                    final user = await signInWithGoogle();
                    if (user != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Logged in as ${user.user?.displayName}")),
                      );
                      // Navigate to your home screen (추가 동작)
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.login),
                      SizedBox(width: 8),
                      Text(
                        "Login with Google",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16,),
                // 카카오 로그인 버튼
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF7B500), // 배경색
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    onKakaoLoginPress(context); // 카카오 로그인 로직 호출
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.login),
                      SizedBox(width: 8),
                      Text(
                        "Login with Kakao",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}