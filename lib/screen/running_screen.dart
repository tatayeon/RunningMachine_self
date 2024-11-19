import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RunningScreen extends StatefulWidget {
  final Function(bool) onRunningStateChange;

  const RunningScreen({Key? key, required this.onRunningStateChange})
      : super(key: key);

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

  double currentSpeed = 0.0;
  DateTime? lastUpdateTime;

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

    startLocationTracking();
  }

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

        final DateTime currentTime = DateTime.now();
        if (lastUpdateTime != null) {
          final elapsed = currentTime.difference(lastUpdateTime!).inSeconds;
          if (elapsed > 0) {
            double speed = (distance / elapsed) * 3.6;
            setState(() {
              currentSpeed = speed;
            });
          }
        }

        setState(() {
          totalDistance += distance / 1000;
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

  void toggleRun() {
    setState(() {
      isRunning = !isRunning;
    });
    widget.onRunningStateChange(isRunning);
    if (isRunning) {
      startTimer();
      startLocationTracking();
    } else {
      stopTimer();
      positionStream.pause();
    }
  }

  Future<void> stopRun() async {
    stopTimer(); // 타이머 멈추기
    positionStream.cancel(); // 위치 추적 멈추기

    // 현재 기록을 Firebase에 저장
    await saveRunToFirebase();

    // 현재 기록을 보여줌
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('운동 종료'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('총 거리: ${totalDistance.toStringAsFixed(2)} km'),
              Text('평균 속도: ${(totalDistance / (elapsedSeconds / 3600)).toStringAsFixed(2)} km/h'),
              Text('총 운동 시간: ${Duration(seconds: elapsedSeconds).inMinutes}분 ${elapsedSeconds % 60}초'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );

    // 기록 초기화
    setState(() {
      isRunning = false; // 상태 업데이트
      widget.onRunningStateChange(isRunning);
      currentSpeed = 0.0; // 속도 초기화
      elapsedSeconds = 0; // 시간 초기화
      totalDistance = 0.0; // 거리 초기화
      routePoints.clear(); // 경로 초기화
    });
  }

  Future<void> saveRunToFirebase() async {
    final runRecord = {
      'distance': totalDistance,
      'time': elapsedSeconds,
      'speed': currentSpeed,
      'timestamp': Timestamp.now(),
    };

    // Firestore에 저장
    await FirebaseFirestore.instance.collection('runs').add(runRecord);
    print('운동 기록이 Firebase에 저장되었습니다.');
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
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Text('이동 거리: ${totalDistance.toStringAsFixed(2)} km'),
                    Text('현재 속도: ${currentSpeed.toStringAsFixed(2)} km/h'),
                    Text('운동 시간: ${elapsedSeconds}s'),
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
          ),
        ],
      ),
    );
  }
}