import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import 'package:csv/csv.dart';
import 'dart:io' show File;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);
const defaultPadding = 16.0;

class ViewMeetings extends StatefulWidget {
  @override
  _ViewMeetingsState createState() => _ViewMeetingsState();
}

class _ViewMeetingsState extends State<ViewMeetings> {
  String query = '';
  DateTime? selectedDate;
  DateTime? startDate;
  DateTime? endDate;

  Stream<List<DocumentSnapshot>> getMeetings() {
    return FirebaseFirestore.instance
        .collection('meetings')
        .orderBy('MeetingDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTimeline(BuildContext context) async {
    final pickedRange = await showDateRangePicker(
      context: context,
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedRange != null) {
      setState(() {
        startDate = pickedRange.start;
        endDate = pickedRange.end;
      });
    }
  }

  void _downloadCsv(List<List<dynamic>> data) async {
    String csvData = const ListToCsvConverter().convert(data);

    if (kIsWeb) {
      // Web: download as before
      final bytes = utf8.encode(csvData);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", "meetings_data.csv")
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Mobile/Desktop: save and share
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/meetings_data.csv');
      await file.writeAsString(csvData);
      await Share.shareXFiles([XFile(file.path)], text: 'Meetings Data CSV');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("View Meetings"),
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Search by First Name, Cell, Meeting',
                labelStyle: TextStyle(color: Colors.white),
                hintText: 'Enter first name, cell, meeting',
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  query = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: ElevatedButton.icon(
              icon: Icon(Icons.calendar_today, color: Colors.white),
              label: Text(
                selectedDate == null
                    ? 'Select Date'
                    : DateFormat('yyyy-MM-dd').format(selectedDate!),
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              onPressed: () => _selectDate(context),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: StreamBuilder<List<DocumentSnapshot>>(
                    stream: getMeetings(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var meetings = snapshot.data!;

                      var filteredMeetings = meetings.where((meeting) {
                        var data = meeting.data() as Map<String, dynamic>;

                        bool matchesQuery = query.isEmpty ||
                            (data['FirstName']?.toString().toLowerCase() ?? '')
                                .contains(query) ||
                            (data['Cell']?.toString().toLowerCase() ?? '')
                                .contains(query) ||
                            (data['Meeting']?.toString().toLowerCase() ?? '')
                                .contains(query);

                        bool matchesDate = selectedDate == null ||
                            (data['MeetingDate'] != null &&
                                data['MeetingDate'] is Timestamp &&
                                DateFormat('yyyy-MM-dd').format(
                                    data['MeetingDate'].toDate()) ==
                                    DateFormat('yyyy-MM-dd')
                                        .format(selectedDate!));

                        bool matchesTimeline = (startDate == null ||
                            endDate == null) ||
                            (data['MeetingDate'] != null &&
                                data['MeetingDate'] is Timestamp &&
                                data['MeetingDate'].toDate().isAfter(startDate!) &&
                                data['MeetingDate'].toDate().isBefore(endDate!));

                        return matchesQuery && matchesDate && matchesTimeline;
                      }).toList();

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(defaultPadding),
                            child: Text(
                              'Attendance: ${filteredMeetings.length}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: defaultPadding),
                            constraints: BoxConstraints(maxWidth: 800),
                            child: Column(
                              children: [
                                // Row for the Download button
                                Row(
                                  children: [
                                     // Pushes the button to the right
                                    ElevatedButton.icon(
                                      icon: Icon(Icons.share, color: Colors.white),
                                      label: Text(
                                        'Share',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                      ),
                                      onPressed: () {
                                        // Prepare CSV data from filtered meetings
                                        List<List<dynamic>> csvData = [
                                          ['First Name', 'Last Name', 'Department', 'Cell', 'Meeting', 'Meeting Date']
                                        ];
                                        for (var meeting in filteredMeetings) {
                                          var data = meeting.data() as Map<String, dynamic>;
                                          String meetingDate = 'N/A';
                                          if (data['MeetingDate'] != null && data['MeetingDate'] is Timestamp) {
                                            meetingDate = DateFormat('yyyy-MM-dd').format(data['MeetingDate'].toDate());
                                          }
                                          csvData.add([
                                            data['FirstName'] ?? '',
                                            data['LastName'] ?? '',
                                            data['Department'] ?? '',
                                            data['Cell'] ?? '',
                                            data['Meeting'] ?? 'No details',
                                            meetingDate
                                          ]);
                                        }
                                        _downloadCsv(csvData);
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: defaultPadding), // Spacing between button and table
                                // DataTable
                                DataTable(
                                  headingRowColor: MaterialStateColor.resolveWith(
                                          (states) => primaryColor),
                                  columns: [
                                    DataColumn(
                                        label: Text('First Name',
                                            style: TextStyle(color: Colors.white))),
                                    DataColumn(
                                        label: Text('Last Name',
                                            style: TextStyle(color: Colors.white))),
                                    DataColumn(
                                        label: Text('Department',
                                            style: TextStyle(color: Colors.white))),
                                    DataColumn(
                                        label: Text('Cell',
                                            style: TextStyle(color: Colors.white))),
                                    DataColumn(
                                        label: Text('Meeting',
                                            style: TextStyle(color: Colors.white))),
                                    DataColumn(
                                        label: Text('Meeting Date',
                                            style: TextStyle(color: Colors.white))),
                                  ],
                                  rows: filteredMeetings.map((meeting) {
                                    var data = meeting.data() as Map<String, dynamic>;

                                    String meetingDetails =
                                        data['Meeting'] ?? 'No details';

                                    String meetingDate = 'N/A';
                                    if (data['MeetingDate'] != null &&
                                        data['MeetingDate'] is Timestamp) {
                                      meetingDate = DateFormat('yyyy-MM-dd')
                                          .format(data['MeetingDate'].toDate());
                                    }

                                    return DataRow(cells: [
                                      DataCell(Text(data['FirstName'] ?? '',
                                          style: TextStyle(color: Colors.white))),
                                      DataCell(Text(data['LastName'] ?? '',
                                          style: TextStyle(color: Colors.white))),
                                      DataCell(Text(data['Department'] ?? '',
                                          style: TextStyle(color: Colors.white))),
                                      DataCell(Text(data['Cell'] ?? '',
                                          style: TextStyle(color: Colors.white))),
                                      DataCell(Text(meetingDetails,
                                          style: TextStyle(color: Colors.white))),
                                      DataCell(Text(meetingDate,
                                          style: TextStyle(color: Colors.white))),
                                    ]);
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _selectTimeline(context),
        label: Text(
          startDate != null && endDate != null
              ? "Timeline: ${DateFormat('yyyy-MM-dd').format(startDate!)} - ${DateFormat('yyyy-MM-dd').format(endDate!)}"
              : "Timeline",
        ),
        icon: Icon(Icons.timeline),
        backgroundColor: primaryColor,
      ),
    );
  }
}