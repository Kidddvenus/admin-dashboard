//Edits the cards to fonts ,size and shape
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../constants.dart';
import 'package:admin/models/my_files.dart';// Designs cards colors and values
import 'package:admin/screens/members.view.screen.dart'; //for viewing the members
import 'package:admin/screens/leaders.view.screen.dart'; //for viewing the leaders
import 'package:admin/screens/cells.view.screen.dart';

class FileInfoCard extends StatefulWidget {
  const FileInfoCard({Key? key, required this.info}) : super(key: key);// const=constructor

  final CloudStorageInfo info;

  @override
  _FileInfoCardState createState() => _FileInfoCardState();
}

class _FileInfoCardState extends State<FileInfoCard> {
  @override
  void initState() {
    super.initState();
    fetchFirestoreCounts().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.info.title == "Members") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MembersTable(),
            ),
          );
        } else if (widget.info.title == "Leaders") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LeadersTable(), // Replace with your widget name
            ),
          );
        } else if (widget.info.title == "Cells") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CellsTable(), // Replace with your widget name
            ),
          );
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          double minHeight = 140;
          if (screenWidth < 600) {
            minHeight = 400;
          }
          return Container(
            padding: EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            constraints: BoxConstraints(minHeight: minHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(defaultPadding * 0.75),
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: widget.info.color!.withOpacity(0.1),
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: SvgPicture.asset(
                        widget.info.svgSrc!,
                        colorFilter: ColorFilter.mode(
                            widget.info.color ?? Colors.black, BlendMode.srcIn),
                      ),
                    ),
                    Text(
                      "${widget.info.numOfMembers}",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Flexible(
                  child: Text(
                    widget.info.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 4),
                Flexible(
                  child: Text(
                    _getCardSubtitle(widget.info.title),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getCardSubtitle(String title) {
    if (title == "Leaders") {
      return "Leaders";
    } else if (title == "Cells") {
      return "Cells";
    } else {
      return "Members";
    }
  }
}
