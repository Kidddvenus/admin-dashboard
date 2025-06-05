//continuation of the generate report screen
//screen for the report summary
import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:admin/screens/report.table.dart';

class ReportScreen extends StatelessWidget {
  final int firstTimersCount;
  final int newConvertsCount;
  final int totalAttendanceCount;
  final int wednesdayCount;
  final int sundayCount;
  final String? specificDate; // Nullable field for specific date
  final String? timeline; // Nullable field for timeline

  const ReportScreen({
    required this.firstTimersCount,
    required this.newConvertsCount,
    required this.totalAttendanceCount,
    required this.wednesdayCount,
    required this.sundayCount,
    this.specificDate, // Optional specific date
    this.timeline, // Optional timeline
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double fontSize = screenSize.width < 400 ? 14 : 18;
    final double paddingSize = screenSize.width < 400 ? 8.0 : defaultPadding;
    final double cardElevation = screenSize.width < 400 ? 3.0 : 5.0;
    final double cardWidth = screenSize.width * 0.9;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Summary'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(paddingSize),
        child: Center(
          child: Card(
            elevation: cardElevation,
            color: secondaryColor,
            child: Container(
              width: cardWidth,
              padding: EdgeInsets.all(paddingSize),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Report Title
                  Text(
                    specificDate != null
                        ? 'Report Summary for $specificDate' // Display specific date if provided
                        : 'Report Summary for $timeline', // Otherwise, show timeline
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: paddingSize),
                  // Table with data
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(1),
                    },
                    border: TableBorder.all(
                      color: Colors.white,
                      width: 1,
                    ),
                    children: [
                      _buildTableRow('First Timers', firstTimersCount, fontSize),
                      _buildTableRow('New Converts', newConvertsCount, fontSize),
                      _buildTableRow('Sundays Attendance', sundayCount, fontSize),
                      _buildTableRow('Wednesdays Attendance', wednesdayCount, fontSize),
                      _buildTableRow('Total Attendance', totalAttendanceCount, fontSize),
                    ],
                  ),
                  SizedBox(height: paddingSize),
                  // View Details Button
                  ElevatedButton(
                    onPressed: () {
                      // Button action
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ReportTableScreen())
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Report Details')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build a table row
  TableRow _buildTableRow(String label, int count, double fontSize) {
    return TableRow(
      children: [
        _buildTableCell(label, fontSize),
        _buildTableCell(count.toString(), fontSize, isCentered: true),
      ],
    );
  }

  // Helper method to build a table cell with borders
  Widget _buildTableCell(String content, double fontSize, {bool isCentered = false}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        content,
        style: TextStyle(color: Colors.white, fontSize: fontSize),
        textAlign: isCentered ? TextAlign.center : TextAlign.start,
      ),
    );
  }
}
