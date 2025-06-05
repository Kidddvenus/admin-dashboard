import 'package:flutter/material.dart';
import '../../../constants.dart';
import 'chart.dart';
import 'datavisual.info.card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StorageDetails extends StatefulWidget {
  const StorageDetails({Key? key}) : super(key: key);

  @override
  _StorageDetailsState createState() => _StorageDetailsState();
}
//Redunduncy in this class the file myfiles.dart has these already
class _StorageDetailsState extends State<StorageDetails> {
  List<CloudStorageInfo> demoMyFiles = [
    CloudStorageInfo(
      title: "Total Members",
      numOfMembers: 0,
      svgSrc: "assets/icons/group-svgrepo-com.svg", // Non-nullable
      color: primaryColor,
    ),
    CloudStorageInfo(
      title: "Members",
      numOfMembers: 0,
      svgSrc: "assets/icons/group-of-people-svgrepo-com.svg", // Non-nullable
      color: const Color(0xFFFFA113),
    ),
    CloudStorageInfo(
      title: "Leaders",
      numOfMembers: 0,
      svgSrc: "assets/icons/group-of-people-svgrepo-com.svg", // Non-nullable
      color: const Color(0xFFA4CDFF),
    ),
    CloudStorageInfo(
      title: "Cells",
      numOfMembers: 0,
      svgSrc: "assets/icons/group-of-people-svgrepo-com.svg", // Non-nullable
      color: const Color(0xFF007EE5),
    ),
  ];

  @override
  void initState() {
    super.initState();
    fetchFirestoreCounts();
  }

  Future<void> fetchFirestoreCounts() async {
    try {
      QuerySnapshot leadersSnapshot = await FirebaseFirestore.instance.collection('leaders').get();
      int leadersCount = leadersSnapshot.size;

      QuerySnapshot membersSnapshot = await FirebaseFirestore.instance.collection('members').get();
      int membersCount = membersSnapshot.size;

      setState(() {
        demoMyFiles[0].numOfMembers = leadersCount + membersCount; // Total Members
        demoMyFiles[1].numOfMembers = membersCount;
        demoMyFiles[2].numOfMembers = leadersCount;
        demoMyFiles[3].numOfMembers = leadersCount; // Assuming Cells = Leaders count
      });
    } catch (e) {
      print('Error fetching Firestore counts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalMembers = demoMyFiles[0].numOfMembers > 0 ? demoMyFiles[0].numOfMembers : 1;

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Data Visual",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: defaultPadding),

          // Pass the dynamic values to Chart
          Chart(
            numOfMembers: demoMyFiles[1].numOfMembers,
            numOfLeaders: demoMyFiles[2].numOfMembers,
             // Pass the non-nullable value here
          ),

          const SizedBox(height: defaultPadding),

          StorageInfoCard(
            svgSrc: demoMyFiles[1].svgSrc, // Non-nullable
            title: demoMyFiles[1].title,
            numOfMembers: demoMyFiles[1].numOfMembers,
            color: const Color(0xFF1DE9B6),
            percentage: (demoMyFiles[1].numOfMembers / totalMembers) * 100,
          ),
          StorageInfoCard(
            svgSrc: demoMyFiles[2].svgSrc, // Non-nullable
            title: demoMyFiles[2].title,
            numOfMembers: demoMyFiles[2].numOfMembers,
            color: const Color(0xFF76FF03),
            percentage: (demoMyFiles[2].numOfMembers / totalMembers) * 100,
          ),
          StorageInfoCard(
            svgSrc: demoMyFiles[0].svgSrc, // Non-nullable
            title: demoMyFiles[0].title,
            numOfMembers: demoMyFiles[0].numOfMembers,
            color: const Color(0xFFFFFA00),
            percentage: 100,
          ),

        ],
      ),
    );
  }
}

class CloudStorageInfo {
  String title;
  int numOfMembers;
  String svgSrc; // Changed to non-nullable
  Color? color;

  CloudStorageInfo({
    required this.title,
    required this.numOfMembers,
    required this.svgSrc, // Non-nullable svgSrc
    this.color,
  });
}

// Initialize with placeholders
