import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

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
  void _showRunsBottomSheet(BuildContext context, List<Map<String, dynamic>> runs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 화면 비율에 따라 자동 조정
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(16),
              child: runs.isEmpty
                  ? Center(child: Text('선택한 날짜의 기록이 없습니다.'))
                  : ListView.builder(
                controller: scrollController,
                itemCount: runs.length,
                itemBuilder: (context, index) {
                  final run = runs[index];
                  return ListTile(
                    leading: Icon(Icons.directions_run, color: Colors.blue),
                    title: Text('거리: ${run['distance'].toStringAsFixed(2)} km'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('시간: ${run['time']} 초'),
                        Text('속도: ${run['speed'].toStringAsFixed(2)} km/h'),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
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



      // 바텀시트 호출
      if (context.mounted) {
        _showRunsBottomSheet(context, runs);
      }
    } catch (e) {
      print('쿼리 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('캘린더'),
      ),
      body: TableCalendar(
        focusedDay: DateTime.now(),
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 1, 1),
        onDaySelected: (selectedDay, focusedDay) {
          _fetchRuns(selectedDay); // 날짜 선택 시 데이터 조회 및 바텀시트 호출
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: false,  // '2 weeks' 텍스트 제거
        ),
      ),
    );
  }
}