import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RuningScreen extends StatelessWidget{
  static final LatLng companyLatLng = LatLng(
    //지도 초기화 위치
    36.834069, //위도
    127.179245, //경도
  );

  const RuningScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: companyLatLng,
          zoom: 16
        ),
      ),
    );
  }

  Future<String> checkPermission() async {
    final isLocationEnabled =
    await Geolocator.isLocationServiceEnabled(); // 위치 서비스 활성화여부 확인

    if (!isLocationEnabled) {
      // 위치 서비스 활성화 안 됨
      return '위치 서비스를 활성화해주세요.';
    }
    LocationPermission checkedPermission =
    await Geolocator.checkPermission(); // 위치 권한 확인

    if (checkedPermission == LocationPermission.denied) {
      // 위치 권한 거절됨
      // 위치 권한 요청하기
      checkedPermission = await Geolocator.requestPermission();
      if (checkedPermission == LocationPermission.denied) {
        return '위치 권한을 허가해주세요.';
      }
    }
    // 위치 권한 거절됨 (앱에서 재요청 불가)
    if (checkedPermission == LocationPermission.deniedForever) {
      return '앱의 위치 권한을 설정에서 허가해주세요.';
    }
    return '위치 권한이 허가 되었습니다.'; // 위 모든 조건이 통과되면 위치 권한 허가완료
  }
}