import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);
const defaultPadding = 16.0;

class LeadersFormScreen extends StatefulWidget {
  @override
  _LeadersFormScreenState createState() => _LeadersFormScreenState();
}

class _LeadersFormScreenState extends State<LeadersFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cellController = TextEditingController();
  final TextEditingController _campusController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _residenceController = TextEditingController();

  String? _selectedMonth;
  int? _selectedDay;
  bool _isSubmitting = false;

  final List<String> _months = List.generate(
    12,
        (index) => DateFormat.MMMM().format(DateTime(2024, index + 1, 1)),
  );

  final List<int> _days = List.generate(31, (index) => index + 1);

  Future<bool> _emailExists(String email) async {
    var leadersSnapshot = await FirebaseFirestore.instance
        .collection('leaders')
        .where('Email', isEqualTo: email)
        .get();
    return leadersSnapshot.docs.isNotEmpty;
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMonth == null || _selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select birth month and day.')),
      );
      return;
    }

    final email = _emailController.text.trim();

    try {
      setState(() {
        _isSubmitting = true;
      });

      if (await _emailExists(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leader already exists.')),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      final data = {
        'FirstName': _firstNameController.text,
        'LastName': _lastNameController.text,
        'Department': _departmentController.text,
        'Phone': _phoneController.text,
        'Cell': _cellController.text,
        'Campus': _campusController.text,
        'Email': email,
        'Residence': _residenceController.text,
        'Birthdate': {
          'month': _selectedMonth,
          'date': _selectedDay,
        },
      };

      await FirebaseFirestore.instance.collection('leaders').add(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data saved successfully!')),
      );

      _formKey.currentState!.reset();
      _clearFields();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save data: $error')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _clearFields() {
    _firstNameController.clear();
    _lastNameController.clear();
    _departmentController.clear();
    _phoneController.clear();
    _cellController.clear();
    _campusController.clear();
    _emailController.clear();
    _residenceController.clear();
    setState(() {
      _selectedMonth = null;
      _selectedDay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Add Leader'),
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 5,
            color: secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(screenWidth < 600 ? 8 : defaultPadding),
            child: Container(
              width: screenWidth < 600 ? screenWidth - 16 : 500, // Responsive width
              padding: EdgeInsets.all(screenWidth < 600 ? 16 : defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField('First Name', _firstNameController),
                    _buildTextField('Last Name', _lastNameController),
                    _buildTextField('Department', _departmentController),
                    _buildTextField('Phone', _phoneController),
                    _buildTextField('Cell', _cellController),
                    _buildTextField('Campus (optional)', _campusController),
                    _buildTextField('Email', _emailController),
                    _buildTextField('Residence', _residenceController),
                    const SizedBox(height: defaultPadding),
                    _buildBirthdateDropdowns(),
                    const SizedBox(height: defaultPadding),
                    Center(
                      child: SizedBox(
                        width: screenWidth < 600 ? 150 : 200, // Responsive button width
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                          ),
                          onPressed: _isSubmitting ? null : _saveData,
                          child: _isSubmitting
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Submit'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: defaultPadding / 2),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: secondaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
          ),
        ),
        validator: (value) {
          if (label != 'Campus (optional)' && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildBirthdateDropdowns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: defaultPadding / 2),
          child: Text(
            'Birthdate',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedMonth,
                decoration: _dropdownDecoration('Month'),
                items: _months.map((month) {
                  return DropdownMenuItem(
                    value: month,
                    child: Text(month, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMonth = value;
                  });
                },
              ),
            ),
            const SizedBox(width: defaultPadding),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _selectedDay,
                decoration: _dropdownDecoration('Day'),
                items: _days.map((day) {
                  return DropdownMenuItem(
                    value: day,
                    child: Text(day.toString(), style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDay = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: secondaryColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
