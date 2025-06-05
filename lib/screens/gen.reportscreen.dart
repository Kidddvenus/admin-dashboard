import 'package:admin/screens/report.summ.screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Constants for colors and default padding
const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);
const double defaultPadding = 16.0;

// GenerateReportScreen widget
class GenerateReportScreen extends StatefulWidget {
  @override
  _GenerateReportScreenState createState() => _GenerateReportScreenState();
}

class _GenerateReportScreenState extends State<GenerateReportScreen> {
  DateTime? selectedDate;
  String? selectedMeetingType;
  DateTimeRange? selectedDateRange;

  // Function to select a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedDateRange = null; // Reset the date range if a specific date is selected
      });
    }
  }

  // Function to select a date range
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
        selectedDate = null; // Reset the specific date if a date range is selected
      });
    }
  }

  // Function to generate the report
  Future<void> _generateReport(BuildContext context) async {
    try {
      // Firestore collections
      CollectionReference firstTimers =
      FirebaseFirestore.instance.collection('firsttimers');
      CollectionReference meetings =
      FirebaseFirestore.instance.collection('meetings');

      // Filters for firstTimers
      Query firstTimersQuery = firstTimers;
      if (selectedDate != null) {
        firstTimersQuery = firstTimersQuery.where(
          'timestamp',
          isEqualTo: Timestamp.fromDate(selectedDate!),
        );
      } else if (selectedDateRange != null) {
        firstTimersQuery = firstTimersQuery.where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(selectedDateRange!.start),
        );
        firstTimersQuery = firstTimersQuery.where(
          'timestamp',
          isLessThanOrEqualTo: Timestamp.fromDate(selectedDateRange!.end),
        );
      }
      QuerySnapshot firstTimersSnapshot = await firstTimersQuery.get();
      int firstTimersCount = firstTimersSnapshot.docs.length;

      // Filters for meetings
      Query meetingsQuery = meetings;
      if (selectedDate != null) {
        meetingsQuery = meetingsQuery.where(
          'MeetingDate',
          isEqualTo: Timestamp.fromDate(selectedDate!),
        );
      } else if (selectedDateRange != null) {
        meetingsQuery = meetingsQuery.where(
          'MeetingDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(selectedDateRange!.start),
        );
        meetingsQuery = meetingsQuery.where(
          'MeetingDate',
          isLessThanOrEqualTo: Timestamp.fromDate(selectedDateRange!.end),
        );
      }
      if (selectedMeetingType != null && selectedMeetingType != 'Both') {
        meetingsQuery = meetingsQuery.where(
          'Meeting',
          isEqualTo: selectedMeetingType,
        );
      }
      QuerySnapshot meetingsSnapshot = await meetingsQuery.get();

      // Count new converts, total attendance, and specific meeting types
      int newConvertsCount = 0;
      int wednesdayCount = 0;
      int sundayCount = 0;
      int totalAttendanceCount = meetingsSnapshot.docs.length;

      for (var doc in meetingsSnapshot.docs) {
        if (doc.data() is Map<String, dynamic>) {
          final data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('NewConvert') && data['NewConvert'] == true) {
            newConvertsCount++;
          }
          // Count attendance (filter by specific meeting dates)
          if (data.containsKey('MeetingDate') &&
              data['MeetingDate'] is Timestamp) {
            Timestamp meetingDate = data['MeetingDate'];
            DateTime meetingDateTime = meetingDate.toDate();
            if (meetingDateTime.weekday == DateTime.wednesday) {
              wednesdayCount++;
            } else if (meetingDateTime.weekday == DateTime.sunday) {
              sundayCount++;
            }
          }
        }
      }

      // Navigate to the report screen with the generated data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReportScreen(
            firstTimersCount: firstTimersCount,
            newConvertsCount: newConvertsCount,
            totalAttendanceCount: totalAttendanceCount,
            wednesdayCount: wednesdayCount,
            sundayCount: sundayCount,
            specificDate: selectedDate != null
                ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                : null,
            timeline: selectedDateRange != null
                ? '${DateFormat('yyyy-MM-dd').format(selectedDateRange!.start)} - ${DateFormat('yyyy-MM-dd').format(selectedDateRange!.end)}'
                : null,
          ),
        ),
      );
    } catch (e) {
      // Handle errors gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating report: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Report'),
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Card(
            elevation: 5,
            color: secondaryColor,
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Card size depends only on content
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: Icon(Icons.calendar_today, color: Colors.white),
                    label: Text(
                      selectedDate != null
                          ? "Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}"
                          : "Select Date",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => _selectDateRange(context),
                    icon: Icon(Icons.timeline_rounded, color: Colors.white),
                    label: Text(
                      selectedDateRange != null
                          ? "Timeline: ${DateFormat('yyyy-MM-dd').format(selectedDateRange!.start)} - ${DateFormat('yyyy-MM-dd').format(selectedDateRange!.end)}"
                          : "Timeline",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => _generateReport(context),
                    icon: Icon(Icons.file_copy_sharp, color: Colors.white),
                    label: Text('Generate Report', style: TextStyle(color: Colors.white, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: bgColor,
    );
  }
}
