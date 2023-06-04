import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'FirebaseNotifications.dart';
import 'home/logout.dart';
import 'home/myreports.dart';
import 'home/notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'home/mainscreen.dart';

int index;

class StartingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return StartingScreenState();
  }
}

class StartingScreenState extends State<StartingScreen> {
  getDetails() async {
    await PermissionHandler().requestPermissions([PermissionGroup.contacts]);
    await PermissionHandler().requestPermissions([PermissionGroup.camera]);
  }
  @override
  void initState() {
    // getDetails();
    FirebaseNotifications().setUpFirebase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            title: Text('Home'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.folder_open),
            title: Text('My Reports'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bell),
            title: Text('Notifications'),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.profile_circled),
            title: Text('Log Out'),
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        assert(index >= 0 && index <= 3);
        switch (index) {
          case 0:
            return MainScreen();
            break;
          case 1:
            return MyReports();
            break;
          case 2:
            return Notifications();
            break;
          case 3:
            return Logout();
            break;
        }
        return null;
      },
    );
  }
}
