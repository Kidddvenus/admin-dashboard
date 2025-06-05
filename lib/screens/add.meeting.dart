import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:admin/screens/firsttimerscreen.dart';

const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);

const defaultPadding = 16.0;

class AddMeetingScreen extends StatefulWidget {
  @override
  _AddMeetingScreenState createState() => _AddMeetingScreenState();
}

class _AddMeetingScreenState extends State<AddMeetingScreen> {
  final TextEditingController _meetingController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;
  Set<int> _selectedRows = {};
  Set<int> _newConvertsRows = {};

  Stream<List<DocumentSnapshot>> getCombinedMembers() {
    Stream<QuerySnapshot> leadersStream =
    FirebaseFirestore.instance.collection('leaders').snapshots();
    Stream<QuerySnapshot> membersStream =
    FirebaseFirestore.instance.collection('members').snapshots();
    Stream<QuerySnapshot> firsttimersStream =
    FirebaseFirestore.instance.collection('firsttimers').snapshots();

    return Rx.combineLatest3(
      leadersStream,
      membersStream,
      firsttimersStream,
          (QuerySnapshot leaders, QuerySnapshot members, QuerySnapshot firsttimers) {
        return [
          ...leaders.docs,
          ...members.docs,
          ...firsttimers.docs,
        ];
      },
    );
  }

  Future<void> _saveMeeting() async {
    if (_meetingController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all the necessary fields.')),
      );
      return;
    }

    for (int index in _selectedRows.union(_newConvertsRows)) {
      var memberData = _filteredMembers[index].data() as Map<String, dynamic>;

      if (memberData['FirstName'] == null ||
          memberData['LastName'] == null ||
          memberData['Birthdate'] == null ||
          memberData['Email'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid member data. Please check and try again.')),
        );
        return;
      }

      try {
        // Check if a meeting already exists for this member
        QuerySnapshot existingMeeting = await FirebaseFirestore.instance
            .collection('meetings')
            .where('FirstName', isEqualTo: memberData['FirstName'])
            .where('LastName', isEqualTo: memberData['LastName'])
            .where('Meeting', isEqualTo: _meetingController.text)
            .where('MeetingDate', isEqualTo: _selectedDate)
            .get();

        if (existingMeeting.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Meeting already exists for ${memberData['FirstName']} ${memberData['LastName']}.'),
            ),
          );
          continue; // Skip adding this meeting
        }

        // Add the meeting
        await FirebaseFirestore.instance.collection('meetings').add({
          'FirstName': memberData['FirstName'],
          'LastName': memberData['LastName'],
          'Department': memberData['Department'] ?? '',
          'Cell': memberData['Cell'] ?? '',
          'Birthdate': memberData['Birthdate'],
          'Email': memberData['Email'],
          'Meeting': _meetingController.text,
          'MeetingDate': _selectedDate,
          'NewConvert': _newConvertsRows.contains(index), // Add NewConvert field
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Meeting added for ${memberData['FirstName']} ${memberData['LastName']}.'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add meeting: $e')),
        );
      }
    }

    setState(() {
      _selectedRows.clear();
      _newConvertsRows.clear();
    });
  }

  List<DocumentSnapshot> _filteredMembers = [];

  Future<void> _showAddMeetingDialog() async {
    _meetingController.clear();
    _selectedDate = null;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: secondaryColor,
        title: Text("Add Meeting", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _meetingController,
              decoration: InputDecoration(
                labelText: 'Meeting',
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: defaultPadding),
            ElevatedButton.icon(
              icon: Icon(Icons.calendar_today),
              label: Text("Select Date"),
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
            ),
            if (_selectedDate != null)
              Text(
                "Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}",
                style: TextStyle(color: Colors.white),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: primaryColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Proceed"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Add Meetings"),
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by First Name',
                hintStyle: TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: secondaryColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {}); // Trigger rebuild for filtering
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _showAddMeetingDialog,
                child: Text("Add Meeting"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
              SizedBox(width: 16), // Add spacing between the buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FirstTimers()),
                  );
                },
                child: Text("First Timers"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: StreamBuilder<List<DocumentSnapshot>>(
                    stream: getCombinedMembers(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var members = snapshot.data!;
                      String searchQuery = _searchController.text.toLowerCase();

                      _filteredMembers = members.where((member) {
                        var data = member.data() as Map<String, dynamic>;
                        return data['FirstName']
                            .toLowerCase()
                            .contains(searchQuery);
                      }).toList();

                      return DataTable(
                        headingRowColor: WidgetStateColor.resolveWith((states) => primaryColor),
                        columns: [
                          DataColumn(label: Text('First Name', style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text('Last Name', style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text('Department', style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text('Birthdate', style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text('Select', style: TextStyle(color: Colors.white))),
                          DataColumn(label: Text('New Converts', style: TextStyle(color: Colors.white))),
                        ],
                        rows: List.generate(_filteredMembers.length, (index) {
                          var data = _filteredMembers[index].data() as Map<String, dynamic>;
                          String birthdateStr =
                              '${data['Birthdate']['month']}-${data['Birthdate']['date']}';

                          return DataRow(
                            cells: [
                              DataCell(Text(data['FirstName'], style: TextStyle(color: Colors.white))),
                              DataCell(Text(data['LastName'], style: TextStyle(color: Colors.white))),
                              DataCell(Text(data['Department'] ?? '', style: TextStyle(color: Colors.white))),
                              DataCell(Text(birthdateStr, style: TextStyle(color: Colors.white))),
                              DataCell(
                                Checkbox(
                                  value: _selectedRows.contains(index),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedRows.add(index);
                                      } else {
                                        _selectedRows.remove(index);
                                      }
                                    });
                                  },
                                ),
                              ),
                              DataCell(
                                Checkbox(
                                  value: _newConvertsRows.contains(index),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _newConvertsRows.add(index);
                                      } else {
                                        _newConvertsRows.remove(index);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: ElevatedButton(
              onPressed: _saveMeeting,
              child: Text("Save"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
