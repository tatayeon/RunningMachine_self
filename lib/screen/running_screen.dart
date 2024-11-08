import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RunningScreen extends StatefulWidget {
  const RunningScreen({Key? key}) : super(key: key);

  @override
  State<RunningScreen> createState() => _RunningScreenState();
}

class _RunningScreenState extends State<RunningScreen> {
  static const LatLng initialLatLng = LatLng(36.834469, 127.149245);
  GoogleMapController? mapController;
  List<LatLng> routePoints = [];
  late StreamSubscription<Position> positionStream;

  bool isRunning = false;
  double totalDistance = 0.0;
  late LatLng lastPosition;

  // 속도 관련 변수
  double currentSpeed = 0.0; // km/h 단위로 속도 표시
  DateTime? lastUpdateTime;

  // 타이머 관련 변수
  Timer? timer;
  int elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  Future<void> checkPermission() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      print('위치 서비스를 활성화해주세요.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('위치 권한을 허가해주세요.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('앱의 위치 권한을 설정에서 허가해주세요.');
      return;
    }

    // 권한이 허가된 경우, 위치 추적 시작
    startLocationTracking();
  }

  // 거리 및 속도 계산 로직
  void startLocationTracking() {
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      if (routePoints.isNotEmpty) {
        double distance = Geolocator.distanceBetween(
          lastPosition.latitude,
          lastPosition.longitude,
          currentLatLng.latitude,
          currentLatLng.longitude,
        );

        // 속도 계산 로직 추가
        final DateTime currentTime = DateTime.now();
        if (lastUpdateTime != null) {
          final elapsed = currentTime.difference(lastUpdateTime!).inSeconds;
          if (elapsed > 0) {
            // m/s 단위 속도를 km/h 단위로 변환
            double speed = (distance / elapsed) * 3.6;
            setState(() {
              currentSpeed = speed; // 현재 속도 업데이트
            });
          }
        }

        setState(() {
          totalDistance += distance / 1000; // 총 이동 거리 누적 (킬로미터 단위)
        });
      }

      setState(() {
        lastPosition = currentLatLng;
        routePoints.add(currentLatLng);
        lastUpdateTime = DateTime.now();
      });

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(currentLatLng),
        );
      }
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        elapsedSeconds++;
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      elapsedSeconds = 0;
    });
  }

  String formatTime(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int remainingSeconds = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void toggleRun() {
    setState(() {
      isRunning = !isRunning;
    });
    if (isRunning) {
      startLocationTracking();
      startTimer();
    } else {
      positionStream.pause();
      stopTimer();
    }
  }

  void stopRun() {
    positionStream.cancel();
    stopTimer();
    setState(() {
      isRunning = false;
      currentSpeed = 0.0; // 종료 시 속도 초기화
    });
  }

  @override
  void dispose() {
    positionStream.cancel();
    stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: initialLatLng,
              zoom: 16,
            ),
            polylines: {
              Polyline(
                polylineId: const PolylineId('route'),
                points: routePoints,
                color: Colors.blue,
                width: 5,
              ),
            },
            onMapCreated: (controller) {
              mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Text('이동 거리: ${totalDistance.toStringAsFixed(2)} km'),
                        Text('현재 속도: ${currentSpeed.toStringAsFixed(2)} km/h'),
                        const SizedBox(height: 10),
                        Text('운동 시간: ${formatTime(elapsedSeconds)}'),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: toggleRun,
                              child: Text(isRunning ? '일시정지' : '시작'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: stopRun,
                              child: const Text('종료'),
                            ),
                          ],
                        ),
                      ],
                    ),
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
