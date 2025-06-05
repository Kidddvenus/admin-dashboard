//styles the chart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../constants.dart';

class StorageInfoCard extends StatelessWidget {
  const StorageInfoCard({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.percentage,
    required this.numOfMembers,
    this.color = Colors.blue, // Add a color parameter with a default value
  }) : super(key: key);

  final String title, svgSrc;
  final double percentage; // Percentage of total
  final int numOfMembers;  // Number of members
  final Color color;       // New color parameter

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: defaultPadding),
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), // Apply color with opacity to background
        border: Border.all(width: 2, color: color.withOpacity(0.7)), // Use color for the border
        borderRadius: const BorderRadius.all(
          Radius.circular(defaultPadding),
        ),
      ),
      child: Row(
        children: [
          // Icon (SVG image)
          SizedBox(
            height: 20,
            width: 20,
            child: SvgPicture.asset(svgSrc), // Use SVG source here
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color, // Set text color to match the provided color
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Display number of members and leaders
                  Text(
                    "$numOfMembers People ",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          // Percentage text
          Text(
            "${percentage.toStringAsFixed(2)}%",
            style: TextStyle(
              color: color, // Set percentage text color to match the provided color
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
