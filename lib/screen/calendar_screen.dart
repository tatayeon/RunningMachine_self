import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  List<Map<String, dynamic>> _runs = [];

  @override
  void initState() {
    super.initState();
    _fetchRuns(_selectedDay);
  }

  Future<void> _fetchRuns(DateTime date) async {
    final startOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day));
    final endOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 23, 59, 59));

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('runs')
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThanOrEqualTo: endOfDay)
          .orderBy('timestamp', descending: false)
          .get();

      final runs = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      setState(() {
        _runs = runs;
      });
    } catch (e) {
      print('쿼리 오류: $e');
    }
  }

  void _showRunDetails(BuildContext context, Map<String, dynamic> run) {
    final List<LatLng> routePoints = (run['route'] as List)
        .map((point) => LatLng(point['latitude'], point['longitude']))
        .toList();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 300,
                width: double.infinity,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: routePoints.isNotEmpty ? routePoints.first : LatLng(0, 0),
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
                  markers: {
                    if (routePoints.isNotEmpty)
                      Marker(
                        markerId: const MarkerId('start'),
                        position: routePoints.first,
                        infoWindow: const InfoWindow(title: '출발 지점'),
                      ),
                    if (routePoints.length > 1)
                      Marker(
                        markerId: const MarkerId('end'),
                        position: routePoints.last,
                        infoWindow: const InfoWindow(title: '종료 지점'),
                      ),
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('총 거리: ${run['distance']} km'),
                    Text('평균 속도: ${run['speed']} km/h'),
                    Text('총 운동 시간: ${Duration(seconds: run['time']).inMinutes}분 ${run['time'] % 60}초'),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('확인'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('캘린더'),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 1, 1),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
              _fetchRuns(selectedDay);
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _runs.length,
              itemBuilder: (context, index) {
                final run = _runs[index];
                return ListTile(
                  leading: Icon(Icons.directions_run, color: Colors.blue),
                  title: Text('거리: ${run['distance']} km'),
                  subtitle: Text('시간: ${run['time']} 초'),
                  onTap: () => _showRunDetails(context, run),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}