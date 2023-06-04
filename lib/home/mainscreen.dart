import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:vtip/StartingScreen.dart';
import 'package:vtip/report.dart';

FirebaseUser user;
var userName;
bool alertMe;

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Future getUserdata() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    userName = pref.getString("name");
    FirebaseAuth _auth = FirebaseAuth.instance;
    user = await _auth.currentUser();
    return user;
  }

  Future sendData(type) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    user = await _auth.currentUser();
    var location = new Location();
    var currentLocation = await location.getLocation();
    var geotag = currentLocation.latitude.toString() +
        " , " +
        currentLocation.longitude.toString();
    print(
        "Latitude : ${currentLocation.latitude}, longitude : ${currentLocation.longitude}");
    var data = await Firestore.instance.collection("reports").add({
      "report": type,
      "email": user.email,
      "time": DateTime.now().toString(),
      "latitude": currentLocation.latitude,
      "longitude": currentLocation.longitude,
      "tag": geotag
    });
    var mytag = await http.get(
        "https://us-central1-v-tip-project.cloudfunctions.net/userReportAdded/${data.documentID}/${currentLocation.latitude}/${currentLocation.longitude}");
    print("recieved tag : ${mytag.body}");
    await http
        .get(
            "https://us-central1-v-tip-project.cloudfunctions.net/sendNotificationToAdmin/$type/${mytag.body}")
        .then((onValue) {
      print(onValue.body);
    });
    Navigator.pop(context);
    return data.documentID;
  }

  @override
  void initState() {
    alertMe = true;
    getUserdata();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: SingleChildScrollView(
      child: FutureBuilder(
          future: getUserdata(),
          builder: (context, _data2) {
            switch (_data2.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
                break;
              case ConnectionState.none:
                return Center(
                  child: Text("Check Your Connection!"),
                );
                break;
              case ConnectionState.active:
                return Center(child: Text("Loading"));
                break;
              case ConnectionState.done:
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 60, left: 20),
                        child: Row(
                          children: <Widget>[
                            Text(
                              "Hello ",
                              style: TextStyle(
                                  color: CupertinoColors.activeBlue,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width / 1.5,
                              child: Text(
                                userName,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 3, left: 20),
                          child: Text(
                            "Welcome to V-TIP",
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w400),
                          )),
                      Container(
                          margin: EdgeInsets.only(top: 35, bottom: 5, left: 20),
                          child: Text(
                            "Something wrong?",
                            style: TextStyle(fontSize: 22),
                          )),
                      Container(
                        margin: EdgeInsets.only(left: 20),
                        child: Text(
                          "Let's Report the incident",
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 30, left: 10, right: 10),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () async {
                                showCupertinoDialog(
                                    context: context,
                                    builder: (context) =>
                                        CupertinoActivityIndicator());
                                var id = await sendData(
                                  "Fire Breakout",
                                );
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Report(
                                              name: "Fire Breakout",
                                              id: id,
                                            )));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black38, width: 1),
                                    borderRadius: BorderRadius.circular(10)),
                                padding: EdgeInsets.only(bottom: 15),
                                height: 150,
                                width: MediaQuery.of(context).size.width / 2.6,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Image.asset("assets/fire.png",
                                        height: 100, width: 100),
                                    Text(
                                      "Fire Breakout",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                showCupertinoDialog(
                                    context: context,
                                    builder: (context) =>
                                        CupertinoActivityIndicator());
                                var id = await sendData("Fight");
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Report(name: "Fight", id: id)));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black38, width: 1),
                                    borderRadius: BorderRadius.circular(10)),
                                padding: EdgeInsets.only(bottom: 15),
                                height: 150,
                                width: MediaQuery.of(context).size.width / 2.6,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Image.asset("assets/fight.png",
                                        height: 100, width: 100),
                                    Text(
                                      "Fight",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 30, left: 10, right: 10),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () async {
                                showCupertinoDialog(
                                    context: context,
                                    builder: (context) =>
                                        CupertinoActivityIndicator());
                                var id = await sendData("Active Shooter");
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Report(
                                            name: "Active Shooter", id: id)));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black38, width: 1),
                                    borderRadius: BorderRadius.circular(10)),
                                padding: EdgeInsets.only(bottom: 15),
                                height: 150,
                                width: MediaQuery.of(context).size.width / 2.6,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Image.asset("assets/shooter.png",
                                        height: 100, width: 100),
                                    Text(
                                      "Active Shooter",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                showCupertinoDialog(
                                    context: context,
                                    builder: (context) =>
                                        CupertinoActivityIndicator());
                                var id = await sendData("Bullying");
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Report(name: "Bullying", id: id)));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black38, width: 1),
                                    borderRadius: BorderRadius.circular(10)),
                                padding: EdgeInsets.only(bottom: 15),
                                height: 150,
                                width: MediaQuery.of(context).size.width / 2.6,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Image.asset("assets/bullying.png",
                                        height: 100, width: 100),
                                    Text(
                                      "Bullying",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 30, left: 20, bottom: 60),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () async {
                                showCupertinoDialog(
                                    context: context,
                                    builder: (context) =>
                                        CupertinoActivityIndicator());
                                var id = await sendData("Drugs");
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Report(name: "Drugs", id: id)));
                              },
                              child: Card(
                                elevation: 0,
                                margin: EdgeInsets.only(
                                    right: MediaQuery.of(context).size.width *
                                            0.1 -
                                        15,
                                    left: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black38, width: 1),
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: EdgeInsets.only(bottom: 15),
                                  height: 150,
                                  width:
                                      MediaQuery.of(context).size.width / 2.6,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Image.asset("assets/drugs.png",
                                          height: 100, width: 100),
                                      Text(
                                        "Drugs",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ]);
            }
          }),
    ));
  }
}
