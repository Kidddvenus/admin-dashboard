//Displays the top 7 populars and uses flutter built in functions for the icons
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../constants.dart';

class RecentFiles extends StatelessWidget {
  const RecentFiles({
    Key? key,
  }) : super(key: key);

  Future<List<RecentFile>> _fetchMeetingData() async {
    // Fetch meetings collection from Firestore
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('meetings').get();

    // Create a map to count occurrences of each email
    Map<String, int> emailCount = {};

    // Create a map to store the most recent data for each email
    Map<String, RecentFile> emailToRecentFile = {};

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Check for the existence of fields and provide defaults if missing
      String firstName = data.containsKey('FirstName') ? data['FirstName'] : "N/A";
      String lastName = data.containsKey('LastName') ? data['LastName'] : "N/A";
      String cell = data.containsKey('Cell') ? data['Cell'] : "N/A";
      String email = data.containsKey('Email') ? data['Email'] : "N/A";

      // Count occurrences of each email
      emailCount[email] = (emailCount[email] ?? 0) + 1;

      // Store the most recent data for each email
      emailToRecentFile[email] = RecentFile(
        firstName: firstName,
        lastName: lastName,
        cell: cell,
        counts: emailCount[email].toString(),
      );
    }

    // Convert the map to a list
    List<RecentFile> meetingList = emailToRecentFile.values.toList();

    // Sort the meeting list by count in descending order
    meetingList.sort((a, b) => int.parse(b.counts!).compareTo(int.parse(a.counts!)));

    // Return the top 7
    return meetingList.take(7).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RecentFile>>(
      future: _fetchMeetingData(), // Fetch data from Firestore
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Show loading spinner while fetching data
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // Handle errors
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data found')); // Handle empty data
        }

        // Data is successfully fetched, display it
        return Container(
          padding: EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Populars",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(
                width: double.infinity,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate column spacing dynamically based on screen width
                    double columnSpacing = constraints.maxWidth / 20;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: columnSpacing,
                        columns: [
                          DataColumn(
                            label: Text("First Name"),
                          ),
                          DataColumn(
                            label: Text("Last Name"),
                          ),
                          DataColumn(
                            label: Text("Cell"),
                          ),
                          DataColumn(
                            label: Text("Counts"),
                          ),
                        ],
                        rows: List.generate(
                          snapshot.data!.length,
                              (index) => recentFileDataRow(snapshot.data![index]),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

DataRow recentFileDataRow(RecentFile fileInfo) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            Icon(
              Icons.person, // Use Flutter's built-in person icon
              color: Color(0xFF00BCD4),
              size: 28, // Set the icon size
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(fileInfo.firstName ?? "N/A"), // Use fallback for null
            ),
          ],
        ),
      ),
      DataCell(Text(fileInfo.lastName ?? "N/A")), // Use fallback for null
      DataCell(Text(fileInfo.cell ?? "N/A")), // Use fallback for null
      DataCell(Text(fileInfo.counts ?? "0")), // Use fallback for null
    ],
  );
}

class RecentFile {
  final String? firstName, lastName, cell, counts;

  RecentFile({
    this.firstName,
    this.lastName,
    this.cell,
    this.counts,
  });
}