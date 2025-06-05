//Cards having the leaders and members and cells
//Designs the card colors and values
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../constants.dart';


class CloudStorageInfo {
  String title;
  int numOfMembers;
  String? svgSrc;
  Color? color;

  CloudStorageInfo({
    required this.title,
    required this.numOfMembers,
    this.svgSrc,
    this.color,
  });
}

// Initialize with placeholders
List<CloudStorageInfo> demoMyFiles = [
  CloudStorageInfo(
    title: "People",
    numOfMembers: 0, // Initialize with 0; updated dynamically
    svgSrc: "assets/icons/group-svgrepo-com.svg",
    color: primaryColor,
  ),
  CloudStorageInfo(
    title: "Members",
    numOfMembers: 0, // Placeholder
    svgSrc: "assets/icons/group-svgrepo-com.svg",
    color: Color(0xFFFFA113),
  ),
  CloudStorageInfo(
    title: "Leaders",
    numOfMembers: 0, // Placeholder
    svgSrc: "assets/icons/group-of-people-svgrepo-com.svg",
    color: Color(0xFFA4CDFF),
  ),
  CloudStorageInfo(
    title: "Cells",
    numOfMembers: 0, // Placeholder
    svgSrc: "assets/icons/group-of-people-svgrepo-com.svg",
    color: Color(0xFF007EE5),
  ),
];

// Functions to fetch document counts from Firestore
Future<void> fetchFirestoreCounts() async { //Future function to fetch document counts from Firestore.
  //async keyword allows asynchronous operations (e.g., Firestore queries).
  try {
    // Fetch Leaders count
    QuerySnapshot leadersSnapshot =
    await FirebaseFirestore.instance.collection('leaders').get();
    int leadersCount = leadersSnapshot.size;

    // Fetch Members count
    QuerySnapshot membersSnapshot =
    await FirebaseFirestore.instance.collection('members').get();
    int membersCount = membersSnapshot.size;

    // Update Total Members count by summing Leaders and Members counts
    demoMyFiles[0].numOfMembers = leadersCount + membersCount; // Total Members

    // Fetch Members count
    demoMyFiles[1].numOfMembers = membersCount; // Members card

    // Fetch Leaders count (also used for Cells)
    demoMyFiles[2].numOfMembers = leadersCount; // Leaders card
    demoMyFiles[3].numOfMembers = leadersCount; // Cells card

  } catch (e) {
    print('Error fetching Firestore counts: $e');
  }
}
