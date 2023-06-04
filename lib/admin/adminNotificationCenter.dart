import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

var status = 0;
Map info;

class FirebaseNotifications {
  FirebaseMessaging _firebaseMessaging;

  void setUpFirebase() {
    _firebaseMessaging = FirebaseMessaging();
    firebaseCloudMessaging_Listeners();
  }

  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) {
      iOS_Permission();
    }
    _firebaseMessaging.getToken().then((token) async {
      QuerySnapshot data =
          await Firestore.instance.collection('devices/devices/admin').getDocuments();
      var ipTempdata = await http.get("http://ip-api.com/json");
      var ipData = jsonDecode(ipTempdata.body);
      for (var i = 0; i < data.documents.length; i++) {
        if (data.documents[i]["token"] == token) {
          status = 1;
          break;
        }
      }
      if (status == 0) {
        CollectionReference ref = Firestore.instance.collection('devices/devices/admin');
        ref.add({"token": token, "ip": ipData, "deviceInfo":info, "time":DateTime.now()});
        print("Admin token saved succesfully");
      } else {
        print("Duplicate Admin token found");
      }
      print("iOS admin token : $token");
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }
}
