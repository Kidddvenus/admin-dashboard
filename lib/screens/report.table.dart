import 'package:flutter/foundation.dart';//for Kisweb
import 'package:flutter/material.dart';// for UI
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';//for calender date
import 'package:csv/csv.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';

class ReportTableScreen extends StatefulWidget {
  final String? specificDate;
  final String? timeline;

  ReportTableScreen({this.specificDate, this.timeline});

  @override
  _ReportTableScreenState createState() => _ReportTableScreenState();
}

class _ReportTableScreenState extends State<ReportTableScreen> {
  late List<Map<String, dynamic>> reportData;

  @override
  void initState() {
    super.initState();
    reportData = [];
    _fetchReportData();
  }

  Future<void> _fetchReportData() async {
    try {
      CollectionReference meetings = FirebaseFirestore.instance.collection('meetings');
      CollectionReference firsttimers = FirebaseFirestore.instance.collection('firsttimers');

      QuerySnapshot meetingsSnapshot = await meetings.get();
      QuerySnapshot firstTimersSnapshot = await firsttimers.get();

      Map<DateTime, List<QueryDocumentSnapshot>> groupedMeetings = {};

      for (var doc in meetingsSnapshot.docs) {
        if (doc.data() is Map<String, dynamic>) {
          final data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('MeetingDate') && data['MeetingDate'] is Timestamp) {
            Timestamp meetingDate = data['MeetingDate'];
            DateTime meetingDateTime = meetingDate.toDate();

            if (!groupedMeetings.containsKey(meetingDateTime)) {
              groupedMeetings[meetingDateTime] = [];
            }
            groupedMeetings[meetingDateTime]!.add(doc);
          }
        }
      }

      for (var meetingDate in groupedMeetings.keys) {
        int newConvertsCount = 0;
        int firstTimersCount = 0;
        int totalAttendanceCount = groupedMeetings[meetingDate]!.length;

        String meeting = '';
        for (var doc in groupedMeetings[meetingDate]!) {
          final data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('Meeting')) {
            meeting = data['Meeting'];
          }
          if (data.containsKey('NewConvert') && data['NewConvert'] == true) {
            newConvertsCount++;
          }
        }

        firstTimersCount = firstTimersSnapshot.docs
            .where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('MeetingDate') && data['MeetingDate'] is Timestamp) {
            Timestamp firstTimerDate = data['MeetingDate'];
            DateTime firstTimerDateTime = firstTimerDate.toDate();
            return firstTimerDateTime.isAtSameMomentAs(meetingDate);
          }
          return false;
        })
            .length;

        reportData.add({
          'MeetingDate': meetingDate,
          'Meeting': meeting,
          'NewConverts': newConvertsCount,
          'FirstTimers': firstTimersCount,
          'TotalAttendance': totalAttendanceCount,
        });
      }

      reportData.sort((a, b) => b['MeetingDate'].compareTo(a['MeetingDate']));

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $e")),
      );
    }
  }

  Future<Uint8List> _generateReportBytes() async {
    // Create CSV data
    List<List<dynamic>> csvData = [
      ['Meeting Date', 'Meeting', 'New Converts', 'First Timers', 'Total Attendance']
    ];

    // Add report data rows
    for (var data in reportData) {
      csvData.add([
        DateFormat('yyyy-MM-dd').format(data['MeetingDate']),
        data['Meeting'],
        data['NewConverts'].toString(),
        data['FirstTimers'].toString(),
        data['TotalAttendance'].toString(),
      ]);
    }

    // Convert to CSV string
    String csv = const ListToCsvConverter().convert(csvData);
    
    // Convert to bytes
    return Uint8List.fromList(csv.codeUnits);
  }

  Future<void> _downloadReport() async {
    try {
      final bytes = await _generateReportBytes();
      
      // Mobile-specific download
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/report.csv'); // Changed to .csv since we're generating CSV
      await file.writeAsBytes(bytes);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Report CSV',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading report: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Table'),
        backgroundColor: Color(0xFF2697FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextButton.icon(
              onPressed: _downloadReport,
              icon: Icon(Icons.share),
              label: Text('Share'),
            ),
            reportData.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('MeetingDate')),
                    DataColumn(label: Text('Meeting')),
                    DataColumn(label: Text('NewConverts')),
                    DataColumn(label: Text('FirstTimers')),
                    DataColumn(label: Text('TotalAttendance')),
                  ],
                  rows: reportData.map((data) {
                    return DataRow(cells: [
                      DataCell(Text(DateFormat('yyyy-MM-dd').format(data['MeetingDate']))),
                      DataCell(Text(data['Meeting'])),
                      DataCell(Text(data['NewConverts'].toString())),
                      DataCell(Text(data['FirstTimers'].toString())),
                      DataCell(Text(data['TotalAttendance'].toString())),
                    ]);
                  }).toList(),
                ),
              ),
            ),
            )
          ],
        ),
      ),
    );
  }
}
