//LOL almost cracked my head cuz i forgot to add admin name and email in admins collection so it couldn't display
//fetches admin name and email then displays allows for changes of those fields too
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Constants
const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);
const defaultPadding = 16.0;

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  String _firstName = '';
  String _email = '';
  bool _isPasswordVisible = false;
  bool _isOldPasswordVisible = false;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      // Fetch user data from Firestore 'admins' collection
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('admins').doc(_user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _firstName = userDoc['FirstName'];
          _email = _user.email ?? '';
          _firstNameController.text = _firstName;
          _emailController.text = _email;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _showChangePasswordDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Change Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _oldPasswordController,
                obscureText: !_isOldPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Old Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isOldPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isOldPasswordVisible = !_isOldPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              TextField(
                controller: _newPasswordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              child: const Text("Change Password"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changePassword() async {
    try {
      String oldPassword = _oldPasswordController.text;
      String newPassword = _newPasswordController.text;

      // Re-authenticate user with the old password
      AuthCredential credential = EmailAuthProvider.credential(
        email: _user.email!,
        password: oldPassword,
      );

      await _user.reauthenticateWithCredential(credential);

      // Change password
      await _user.updatePassword(newPassword);

      // Inform the user of success
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Password changed successfully."),
      ));

      // Close the dialog
      Navigator.of(context).pop();
    } catch (e) {
      print('Error changing password: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to change password. Please try again."),
      ));
    }
  }

  Future<void> _updateUserProfile() async {
    try {
      String newFirstName = _firstNameController.text;
      String newEmail = _emailController.text;

      // Update FirstName in Firestore
      await FirebaseFirestore.instance.collection('admins').doc(_user.uid).update({
        'FirstName': newFirstName,
      });

      // Update Email in Firebase Authentication
      await _user.updateEmail(newEmail);

      setState(() {
        _firstName = newFirstName;
        _email = newEmail;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Profile updated successfully."),
      ));
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Failed to update profile. Please try again."),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text("User Profile"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            color: secondaryColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(screenWidth < 600 ? 8 : defaultPadding),
            child: Container(
              width: screenWidth < 600 ? screenWidth - 32 : 400, // Responsive width
              padding: EdgeInsets.all(screenWidth < 600 ? 16 : defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile icon at the top center of the card
                  Icon(
                    Icons.account_circle,
                    size: screenWidth < 600 ? 80 : 100, // Responsive icon size
                    color: primaryColor,
                  ),
                  SizedBox(height: 16),
                  // User name with pencil icon to edit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          _firstName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth < 600 ? 20 : 24, // Responsive font size
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis, // Prevent overflow
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: primaryColor),
                        onPressed: () {
                          // Open dialog to edit FirstName
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Edit First Name"),
                                content: TextField(
                                  controller: _firstNameController,
                                  decoration: InputDecoration(
                                    labelText: 'New First Name',
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _updateUserProfile();
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                    ),
                                    child: Text("Save"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Cancel"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Email with pencil icon to edit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          _email,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: screenWidth < 600 ? 14 : 16, // Responsive font size
                          ),
                          overflow: TextOverflow.ellipsis, // Prevent overflow
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: primaryColor),
                        onPressed: () {
                          // Open dialog to edit email
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Edit Email"),
                                content: TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'New Email',
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _updateUserProfile();
                                      Navigator.of(context).pop();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                    ),
                                    child: Text("Save"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Cancel"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showChangePasswordDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                    ),
                    child: Text("Change Password"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
