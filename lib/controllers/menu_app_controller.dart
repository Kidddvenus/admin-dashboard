import 'package:flutter/material.dart';//for creating the widget and designing it

class MenuAppController extends ChangeNotifier {// Indicates MenuAppController is a subclass of ChangeNotifier-flutter utility class used
  //to provide mechanisms for listeners to notify changes, provides state management and changes in UI
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();//final keyword makes the scaffold immutable once
  //assigned it can't be changed
  //GlobalKey<ScaffoldState>: This declares a GlobalKey that is specifically tied to the ScaffoldState of a Scaffold widget.
  //GlobalKey: A unique key used to access a widget's state or methods, such as opening a Drawer or showing a Snackbar
  //ScaffoldState: The state object for a Scaffold widget. It allows control over scaffold-related functionality, like opening a Drawer.

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  void controlMenu() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }
}
