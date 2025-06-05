import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin/constants.dart';  // Import constants only

class CellsTable extends StatefulWidget {
  @override
  _CellsTableState createState() => _CellsTableState();
}

class _CellsTableState extends State<CellsTable> {
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
          .map((doc) => doc.data() as Map<String, dynamic>)
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
        final cell = member['Cell'].toLowerCase();
        return cell.contains(query);
      }).toList();
    });
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
        title: Text('Cells'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
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
            SizedBox(height: defaultPadding),
            // Table displaying members
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical, // Allow vertical scrolling
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Allow horizontal scrolling
                  child: DataTable(
                    headingRowColor: WidgetStateColor.resolveWith((states) => primaryColor), // Same color as the app bar
                    columns: [
                      DataColumn(label: Text('First Name', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Last Name', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Department', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Cell', style: TextStyle(color: Colors.white))),
                      DataColumn(label: Text('Phone', style: TextStyle(color: Colors.white))),
                    ],
                    rows: _filteredMembers.map((member) {
                      return DataRow(
                        color: WidgetStateColor.resolveWith((states) => secondaryColor.withOpacity(0.1)),
                        cells: [
                          DataCell(Text(member['FirstName'], style: TextStyle(color: Colors.white))),
                          DataCell(Text(member['LastName'], style: TextStyle(color: Colors.white))),
                          DataCell(Text(member['Department'], style: TextStyle(color: Colors.white))),
                          DataCell(Text(member['Cell'], style: TextStyle(color: Colors.white))),
                          DataCell(Text(member['Phone'], style: TextStyle(color: Colors.white))),
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
