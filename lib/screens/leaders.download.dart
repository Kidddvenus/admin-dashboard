//decoy
//Downloads the leaders collection in CSV

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'dart:html' as html; // Import for web-specific functionality ,almost cracked my head on this import LOL

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ExportLeadersScreen(),
    );
  }
}

class ExportLeadersScreen extends StatelessWidget {
  Future<void> exportDataToCsv() async {
    // Request storage permission for saving the file
    if (!await _requestPermission()) return;

    // Create CSV header
    String csvData = 'FirstName,LastName,Department,Campus,Cell,Phone,Email,Residence,Birthdate\n';

    // Fetch Firestore data (replace with your collection and query)
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('leaders').get();

    // Loop through Firestore data and add to CSV string
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      Map<String, dynamic> data = querySnapshot.docs[i].data() as Map<String, dynamic>;

      // Birthdate map handling: format it as a string "7 June"
      String birthdate = "${data['Birthdate']['date']} ${data['Birthdate']['month']}";

      // Add each field to the CSV row
      csvData += '${data['FirstName'] ?? ''},${data['LastName'] ?? ''},${data['Department'] ?? ''},${data['Campus'] ?? ''},${data['Cell'] ?? ''},${data['Phone'] ?? ''},${data['Email'] ?? ''},${data['Residence'] ?? ''},$birthdate\n';
    }

    // Save the CSV file
    if (kIsWeb) {
      // Web-specific solution using dart:html
      _downloadCsvForWeb(csvData);
    } else {
      // Mobile platforms: save the file to device storage
      Directory? directory = await getDownloadsDirectory();
      if (directory != null) {
        String outputFile = '${directory.path}/leaders_data.csv';
        File(outputFile)
          ..createSync(recursive: true)
          ..writeAsStringSync(csvData);

        _showSnackBar('File saved to $outputFile');
      } else {
        _showSnackBar('Unable to access downloads directory');
      }
    }
  }

  Future<bool> _requestPermission() async {
    // Skip permission request for Web
    if (kIsWeb) {
      print("Web: No permission needed for storage.");
      return true; // Web doesn't require storage permission
    }

    // For mobile platforms, request storage permission
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  void _downloadCsvForWeb(String csvData) {
    // Web: Download using dart:html library
    final encodedCsv = Uint8List.fromList(csvData.codeUnits); // Convert to Uint8List
    final blob = html.Blob([encodedCsv], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = 'leaders_data.csv'
      ..click();
    html.Url.revokeObjectUrl(url);
    _showSnackBar('Download initiated for Web');
  }

  void _showSnackBar(String message) {
    // This ensures the SnackBar is displayed after the build context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  BuildContext? _context;

  @override
  Widget build(BuildContext context) {
    _context = context; // Store context for SnackBar
    return Scaffold(
      appBar: AppBar(title: Text('Download Leaders Data')),
      body: Center(
        child: ElevatedButton(
          onPressed: exportDataToCsv,
          child: Text('Download Leaders Data as CSV'),
        ),
      ),
    );
  }
}
