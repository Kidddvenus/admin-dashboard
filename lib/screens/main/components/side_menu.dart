import 'package:admin/screens/add.meeting.dart';
import 'package:admin/screens/leaders.form.screen.dart';
import 'package:admin/screens/members.form.screen.dart';
import 'package:admin/screens/view.meetings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:admin/screens/loginscreen.dart';
import 'package:admin/screens/profile.screen.dart';
import 'package:admin/screens/fileuploads.dart';
import 'package:admin/screens/gen.reportscreen.dart';
// Import the DashboardScreen class here

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/adminlogo.png"),
          ),

          DrawerListTile(
            title: "Add Leader",
            svgSrc: "assets/icons/new-registration-icon.svg",
            press: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LeadersFormScreen()),
              );
            },
          ),
          DrawerListTile(
            title: "Add Member",
            svgSrc: "assets/icons/new-registration-icon.svg",
            press: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MembersFormScreen()),
              );
            },
          ),
          DrawerListTile(
            title: "Add Meeting",
            svgSrc: "assets/icons/new-registration-icon.svg",
            press: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => AddMeetingScreen()),
              );
            },
          ),
          DrawerListTile(
            title: "View Meetings",
            svgSrc: "assets/icons/view-alt-svgrepo-com.svg",
            press: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ViewMeetings()),
              );
            },
          ),
          DrawerListTile(
              title: 'Reports',
              svgSrc: 'assets/icons/audit-report-survey-icon.svg',
              press: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => GenerateReportScreen()),
                );

              },
          ),
          DrawerListTile(
            title: "Gallery",
            svgSrc: "assets/icons/photo-gallery-icon.svg",
            press: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ImageGallery()),
              );
            },
          ),
          DrawerListTile(
            title: "Profile",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserProfileScreen()),
              );
            },
          ),
          DrawerListTile(
            title: "Sign Out",
            svgSrc: "assets/icons/sign-out-svgrepo-com.svg",
            press: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
