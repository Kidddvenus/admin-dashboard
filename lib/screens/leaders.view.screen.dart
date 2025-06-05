import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin/constants.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class LeadersTable extends StatefulWidget {
  @override
  _LeadersTableState createState() => _LeadersTableState();
}

class _LeadersTableState extends State<LeadersTable> {
  late Future<List<Map<String, dynamic>>> _leadersFuture;
  List<Map<String, dynamic>> _leaders = [];
  List<Map<String, dynamic>> _filteredLeaders = [];

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _cellController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _leadersFuture = fetchLeaders();
    _firstNameController.addListener(_filterLeaders);
    _cellController.addListener(_filterLeaders);
  }

  Future<List<Map<String, dynamic>>> fetchLeaders() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('leaders').get();
      final leaders = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>..['id'] = doc.id) // Add 'id' field to each leader
          .toList();
      setState(() {
        _leaders = leaders;
        _filteredLeaders = leaders; // Initialize filtered list with all data
      });
      return leaders;
    } catch (e) {
      print('Error fetching leaders: $e');
      return [];
    }
  }

  void _filterLeaders() {
    final firstNameQuery = _firstNameController.text.toLowerCase();
    final cellQuery = _cellController.text.toLowerCase();

    setState(() {
      _filteredLeaders = _leaders.where((leader) {
        final firstName = leader['FirstName'].toLowerCase();
        final cell = leader['Cell'].toLowerCase();
        return firstName.contains(firstNameQuery) && cell.contains(cellQuery);
      }).toList();
    });
  }

  Future<void> _updateLeader(Map<String, dynamic> leader) async {
    // Show the update dialog with editable fields
    TextEditingController cellController =
    TextEditingController(text: leader['Cell']);
    TextEditingController residenceController =
    TextEditingController(text: leader['Residence']);
    TextEditingController phoneController =
    TextEditingController(text: leader['Phone']);
    TextEditingController emailController =
    TextEditingController(text: leader['Email']);
    TextEditingController departmentController =
    TextEditingController(text: leader['Department']); // Added Department

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Leader'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: cellController,
                  decoration: InputDecoration(labelText: 'Cell'),
                ),
                TextField(
                  controller: residenceController,
                  decoration: InputDecoration(labelText: 'Residence'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: departmentController, // Added Department
                  decoration: InputDecoration(labelText: 'Department'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Gather updated values
                final updatedLeader = {
                  'Cell': cellController.text,
                  'Residence': residenceController.text,
                  'Phone': phoneController.text,
                  'Email': emailController.text,
                  'Department': departmentController.text, // Include Department
                };

                try {
                  // Update the leader document in Firestore
                  await FirebaseFirestore.instance
                      .collection('leaders')
                      .doc(leader['id']) // Using the correct ID
                      .update(updatedLeader)
                      .then((_) {
                    // Close the dialog
                    Navigator.pop(context);
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Leader updated successfully')),
                    );
                    // Refresh the table data after update
                    setState(() {
                      _leaders = _leaders.map((e) {
                        if (e['id'] == leader['id']) {
                          return {...e, ...updatedLeader}; // Update the leader in the list
                        }
                        return e;
                      }).toList();
                      _filteredLeaders = _leaders; // Reset filtered list
                    });
                  });
                } catch (e) {
                  print('Error updating leader: $e');
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _downloadCsv() async {
    String csvData = 'FirstName,LastName,Department,Campus,Cell,Phone,Email,Residence,Birthdate,InvitedBy\n';

    for (var leader in _filteredLeaders) {
      String birthdate = "${leader['Birthdate']['date']} ${leader['Birthdate']['month']}";
      csvData += '${leader['FirstName']},${leader['LastName']},${leader['Department']},${leader['Campus']},${leader['Cell']},${leader['Phone']},${leader['Email']},${leader['Residence']},$birthdate,${leader['InvitedBy']}\n';
    }

    final encodedCsv = Uint8List.fromList(csvData.codeUnits);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/leaders_data.csv');
      await file.writeAsBytes(encodedCsv);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Leaders Data CSV',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving CSV: $e')),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _cellController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Leaders'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            // Row with Search bar for both First Name and Cell
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _firstNameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Search by First Name',
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: secondaryColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.white70),
                    ),
                  ),
                ),
                SizedBox(width: defaultPadding),
                Expanded(
                  child: TextField(
                    controller: _cellController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Search by Cell',
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: secondaryColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.white70),
                    ),
                  ),
                ),
                SizedBox(width: defaultPadding),
                IconButton(
                  icon: Icon(Icons.share, color: Colors.white),
                  onPressed: _downloadCsv,
                ),
              ],
            ),
            SizedBox(height: defaultPadding),
            // Table displaying leaders
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical, // Allow vertical scrolling
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Allow horizontal scrolling
                  child: DataTable(
                    headingRowColor: WidgetStateColor.resolveWith(
                            (states) => primaryColor), // Same color as the app bar
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
                          label: Text('Campus',
                              style: TextStyle(color: Colors.white))),
                      DataColumn(
                          label: Text('Birthdate',
                              style: TextStyle(color: Colors.white))),
                      DataColumn(
                          label: Text('Phone',
                              style: TextStyle(color: Colors.white))),
                      DataColumn(
                          label: Text('Email',
                              style: TextStyle(color: Colors.white))),
                      DataColumn(
                          label: Text('Residence',
                              style: TextStyle(color: Colors.white))),
                      DataColumn(
                          label: Text('Actions',
                              style: TextStyle(color: Colors.white))), // Edit action column
                    ],
                    rows: _filteredLeaders.map((leader) {
                      return DataRow(
                        color: WidgetStateColor.resolveWith(
                                (states) => secondaryColor.withOpacity(0.1)),
                        cells: [
                          DataCell(Text(leader['FirstName'],
                              style: TextStyle(color: Colors.white))),
                          DataCell(Text(leader['LastName'],
                              style: TextStyle(color: Colors.white))),
                          DataCell(Text(leader['Department'],
                              style: TextStyle(color: Colors.white))),
                          DataCell(Text(leader['Cell'],
                              style: TextStyle(color: Colors.white))),
                          DataCell(Text(leader['Campus'],
                              style: TextStyle(color: Colors.white))),
                          DataCell(Text(
                              '${leader['Birthdate']['date']} ${leader['Birthdate']['month']}',
                              style: TextStyle(color: Colors.white))),
                          DataCell(Text(leader['Phone'],
                              style: TextStyle(color: Colors.white))),
                          DataCell(Text(leader['Email'],
                              style: TextStyle(color: Colors.white))),
                          DataCell(Text(leader['Residence'],
                              style: TextStyle(color: Colors.white))),
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.white70),
                              onPressed: () => _updateLeader(leader),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
