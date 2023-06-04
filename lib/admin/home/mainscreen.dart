import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:convert';
import 'package:vtip/StartingScreen.dart';
import 'package:vtip/admin/home/tabs/tab1.dart';
import 'package:vtip/admin/home/tabs/tab3.dart';
import 'package:vtip/admin/home/tabs/taggingForm.dart';
import 'package:vtip/report.dart';
import './tabs/tab3.dart';
import 'tabs/tab2.dart';

FirebaseUser user;
int sharedValue = 0;

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Future getUserdata() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    user = await _auth.currentUser();
    return user;
  }

  final Map<int, Widget> tabs = <int, Widget>{
    0: Tab1(),
    1: Container(
      margin: EdgeInsets.all(10),
      child: Tab2(),
    ),
    2: Center(child: Tab3()),
  };

  final Map<int, Widget> children = const <int, Widget>{
    0: Text('Issues'),
    1: Text('Heat Maps'),
    2: Text('Tagging'),
  };

  @override
  void initState() {
    getUserdata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 30,
          margin: EdgeInsets.only(top: 80, left: 30),
          child: Row(
            children: <Widget>[
              Text(
                "Hello ",
                style: TextStyle(
                    // color: Color(0xff0bc548),
                    color: CupertinoColors.activeBlue,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "Admin",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
              )
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 30),
          height: 50,
          child: Text(
            "Welcome to V-TIP",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
          ),
        ),

        //Tabbar Content starts here
        Container(
          height: MediaQuery.of(context).size.height - 200,
          child: Column(
            children: <Widget>[
              //Tabbar widget
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: CupertinoSegmentedControl<int>(
                  children: children,
                  onValueChanged: (int newValue) {
                    setState(() {
                      sharedValue = newValue;
                    });
                  },
                  groupValue: sharedValue,
                ),
              ),

              //Tabbar content
              Container(
                height: MediaQuery.of(context).size.height - 270,
                child: tabs[sharedValue],
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
