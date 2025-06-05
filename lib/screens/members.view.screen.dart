import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin/constants.dart';  // Import constants only
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class MembersTable extends StatefulWidget {
  @override
  _MembersTableState createState() => _MembersTableState();
}

class _MembersTableState extends State<MembersTable> {
  late Future<List<Map<String, dynamic>>> _membersFuture;
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _filteredMembers = [];

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _membersFuture = fetchMembers();
    _searchController.addListener(_filterMembers);
  }

  Future<List<Map<String, dynamic>>> fetchMembers() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('members').get();
      final members = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>..['id'] = doc.id) // Add 'id' field to each member
          .toList();
      setState(() {
        _members = members;
        _filteredMembers = members; // Initialize filtered list with all data
      });
      return members;
    } catch (e) {
      print('Error fetching members: $e');
      return [];
    }
  }

  void _filterMembers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMembers = _members.where((member) {
        final firstName = member['FirstName'].toLowerCase();
        return firstName.contains(query);
      }).toList();
    });
  }

  Future<void> _updateMember(Map<String, dynamic> member) async {
    // Show the update dialog with editable fields
    TextEditingController cellController =
    TextEditingController(text: member['Cell']);
    TextEditingController residenceController =
    TextEditingController(text: member['Residence']);
    TextEditingController phoneController =
    TextEditingController(text: member['Phone']);
    TextEditingController emailController =
    TextEditingController(text: member['Email']);
    TextEditingController departmentController =
    TextEditingController(text: member['Department']); // Added Department

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Member'),
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
                final updatedMember = {
                  'Cell': cellController.text,
                  'Residence': residenceController.text,
                  'Phone': phoneController.text,
                  'Email': emailController.text,
                  'Department': departmentController.text, // Include Department
                };

                try {
                  // Update the member document in Firestore
                  await FirebaseFirestore.instance
                      .collection('members')
                      .doc(member['id']) // Using the correct ID
                      .update(updatedMember)
                      .then((_) {
                    // Close the dialog
                    Navigator.pop(context);
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Member updated successfully')),
                    );
                    // Refresh the table data after update
                    setState(() {
                      _members = _members.map((e) {
                        if (e['id'] == member['id']) {
                          return {...e, ...updatedMember}; // Update the member in the list
                        }
                        return e;
                      }).toList();
                      _filteredMembers = _members; // Reset filtered list
                    });
                  });
                } catch (e) {
                  print('Error updating member: $e');
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

    for (var member in _filteredMembers) {
      String birthdate = "${member['Birthdate']['date']} ${member['Birthdate']['month']}";
      csvData += '${member['FirstName']},${member['LastName']},${member['Department']},${member['Campus']},${member['Cell']},${member['Phone']},${member['Email']},${member['Residence']},$birthdate,${member['InvitedBy']}\n';
    }

    final encodedCsv = Uint8List.fromList(csvData.codeUnits);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/members_data.csv');
      await file.writeAsBytes(encodedCsv);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Members Data CSV',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving CSV: $e')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Members'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            // Row with Search bar and Download button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
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
                IconButton(
                  icon: Icon(Icons.share, color: Colors.white),
                  onPressed: _downloadCsv,
                ),
              ],
            ),
            SizedBox(height: defaultPadding),
            // Table displaying members
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical, // Allow vertical scrolling
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Allow horizontal scrolling
                  child: DataTable(
                    headingRowColor:
                    WidgetStateColor.resolveWith((states) => primaryColor), // Same color as the app bar
                    columns: [
                      DataColumn(label: Text('First Name', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Last Name', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Department', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Cell', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Campus', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Birthdate', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Phone', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Email', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Residence', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Invited By', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Actions', style: TextStyle(color: Colors.white))), // Edit action column
                    ],
                    rows: _filteredMembers.map((member) {
                      return DataRow(
                        color: WidgetStateColor.resolveWith((states) => secondaryColor.withOpacity(0.1)),
                        cells: [
                          DataCell(Text(member['FirstName'], style: TextStyle(color: Colors.white))),
                          DataCell(Text(member['LastName'], style: TextStyle(color: Colors.white))),
                          DataCell(Text(member['Department'], style: TextStyle(color: Colors.white))),
                          DataCell(Text(member['Cell'], style: TextStyle(color: Colors.white))),
                          DataCell(Text(member['Campus'], style: TextStyle(color: Colors.white))),
                          DataCell(Text('${member['Birthdate']['date']} ${member['Birthdate']['month']}', style: TextStyle(color: Colors.white))),
                          DataCell(Text(member['Phone'], style: TextStyle(color: Colors.white))),
                          DataCell(Text(member['Email'], style: TextStyle(color: Colors.white))),
                          DataCell(Text(member['Residence'], style: TextStyle(color: Colors.white))),
                          DataCell(Text(member['InvitedBy'], style: TextStyle(color: Colors.white))),
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.white),
                              onPressed: () => _updateMember(member),
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
