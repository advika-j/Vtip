import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:vtip/admin/adminNotificationCenter.dart';
import 'home/logout.dart';
import 'home/myreports.dart';
import 'home/notifications.dart';
import 'home/mainscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

int index;
var email;
bool tokenExists,status;
FirebaseMessaging _firebaseMessaging;
Map info;

class AdminStartingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AdminStartingScreenState();
  }
}

class AdminStartingScreenState extends State<AdminStartingScreen> {
  // getDetails() async {
  //   await PermissionHandler().requestPermissions([PermissionGroup.contacts]);
  //   await PermissionHandler().requestPermissions([PermissionGroup.camera]);
  // }

  getUserData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    email = pref.getString("email");
    print(email);
  }

  storeToken() async {
   _firebaseMessaging.getToken().then((token) async {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      info={
        "model" : androidInfo.model,
        "device":androidInfo.device,
        "product":androidInfo.product,
        "androidID" : androidInfo.androidId,
        "brand":androidInfo.brand
      };
      QuerySnapshot data =
          await Firestore.instance.collection('devices/devices/admin').getDocuments();
      var ipTempdata = await http.get("http://ip-api.com/json");
      var ipData = jsonDecode(ipTempdata.body);
      var location = Location();
      var currentLocation = await location.getLocation();
      Map<String, String> coordinates =  {
        "longitude" : currentLocation.longitude.toString(),
        "lattitude" : currentLocation.latitude.toString()
      };
      for (var i = 0; i < data.documents.length; i++) {
        if (data.documents[i]["id"] == token) {
          status = true;
          break;
        }
      }
      if (status == false) {
        DocumentReference ref = Firestore.instance.document("devices/devices/admin/" + email);
        ref.setData({"id": token, "ip": ipData, "deviceInfo":info, "location" : coordinates});
        print("token saved succesfully");
      } else {
        print("Duplicate token found");
      }
      print(token);
    });
  }

  @override
  void initState() {
    status = false;
    // storeToken();
    // getDetails();
    FirebaseNotifications().setUpFirebase();
    getUserData();
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
            icon: Icon(CupertinoIcons.book),
            title: Text('Reports'),
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
