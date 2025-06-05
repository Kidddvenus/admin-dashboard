//design the card
//Responsible for the responsiveness of the cards on various screens
import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:admin/models/my_files.dart';//Designs cards colors and values
import '../../../constants.dart';
import 'cards.dart';

class MyFiles extends StatelessWidget {
  const MyFiles({
    Key? key,
  }) : super(key: key);

  @override//Indicates that the build method overrides the base class (StatelessWidget) implementation.
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;//Captures the screen size (width and height) using Flutter's MediaQuery.
    return Column(//Defines a column on the widget
      children: [
        Row(// Defines a row inside a column
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Overview",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ElevatedButton.icon(//an icon that is a button
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 1.5,
                  vertical:
                      defaultPadding / (Responsive.isMobile(context) ? 3 : 1),
                ),
              ),
              onPressed: () {},
              icon: Icon(Icons.add),
              label: Text("Add New"),
            ),
          ],
        ),
        SizedBox(height: defaultPadding),
        Responsive(
          mobile: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: _size.width,
              child: FileInfoCardGridView(
                crossAxisCount: 1,
                childAspectRatio: _size.width < 600 ? 2.2 : 1.6,
              ),
            ),
          ),
          tablet: FileInfoCardGridView(),
          desktop: FileInfoCardGridView(
            childAspectRatio: _size.width < 1400 ? 1.1 : 1.4,
          ),
        ),
      ],
    );
  }
}

class FileInfoCardGridView extends StatelessWidget {
  const FileInfoCardGridView({
    Key? key,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1,
  }) : super(key: key);

  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: demoMyFiles.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => FileInfoCard(info: demoMyFiles[index]),
    );
  }
}
