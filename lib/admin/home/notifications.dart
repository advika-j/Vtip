import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

var comment, title;
bool btnStatus;
GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
TextEditingController _ctrl = TextEditingController();
TextEditingController _ctrl2 = TextEditingController();

final _formKey = GlobalKey<FormState>();

class Notifications extends StatefulWidget {
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  String titleFun(String data) {
    if (!data.isNotEmpty)
      return "This field can\'t be null";
    else
      return null;
  }

  String reportFun(String data) {
    if (!data.isNotEmpty)
      return "This field can\'t be null";
    else
      return null;
  }

  timepass() async {
    await Future.delayed(Duration(seconds: 2));
    return true;
  }

  @override
  void initState() {
    btnStatus = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            children: <Widget>[
              Container(
                height: 80,
                padding: EdgeInsets.only(bottom: 10, left: 30),
                alignment: Alignment.bottomLeft,
                width: MediaQuery.of(context).size.width,
                color: CupertinoColors.activeBlue,
                child: Text(
                  "Notifications",
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20,color: Colors.white),
                ),
              ),
              Container(
                  height: MediaQuery.of(context).size.height - 140,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: 60),
                  child: SingleChildScrollView(
                    child: Column(children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 60),
                        child: Icon(
                          CupertinoIcons.bell,
                          size: 120,
                          color: CupertinoColors.activeBlue,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Text("Broadcast",
                            style: TextStyle(
                                color: CupertinoColors.activeBlue,
                                fontSize: 40)),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Text("Notification",
                            style: TextStyle(
                                color: CupertinoColors.activeBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 40)),
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin:
                                  EdgeInsets.only(left: 20, right: 20, top: 20),
                              child: TextFormField(
                                controller: _ctrl,
                                decoration: InputDecoration(
                                    hintText: "Title",
                                    hintStyle: TextStyle(
                                      color: CupertinoColors.activeBlue,
                                      wordSpacing: 4,
                                      letterSpacing: 1,
                                    )),
                                onChanged: (data) {
                                  title = data;
                                  print(data);
                                },
                                validator: titleFun,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 18, top: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.black26)),
                              height: 200,
                              margin: EdgeInsets.all(20),
                              child: TextFormField(
                                  controller: _ctrl2,
                                  initialValue: null,
                                  style: TextStyle(
                                      color: Colors.black54,
                                      wordSpacing: 4,
                                      letterSpacing: 1),
                                  decoration: InputDecoration(
                                      labelStyle: TextStyle(color: Colors.red),
                                      border: InputBorder.none,
                                      hintText: "Notify your Students",
                                      hintStyle: TextStyle(
                                        color: CupertinoColors.activeBlue,
                                        wordSpacing: 4,
                                        letterSpacing: 1,
                                      )),
                                  minLines: 10,
                                  maxLengthEnforced: true,
                                  maxLines: 30,
                                  autocorrect: false,
                                  onChanged: (data) {
                                    comment = data;
                                    print(data);
                                  },
                                  validator: reportFun),
                            ),
                            (btnStatus)
                                ? CupertinoButton(
                                    color: CupertinoColors.activeBlue,
                                    child: Text(
                                      'Submit',
                                      style: TextStyle(
                                        color: CupertinoColors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState.validate()) {
                                        setState(() {
                                          btnStatus = !btnStatus;
                                        });
                                        print("fields are validated");
                                        await Firestore.instance
                                            .collection("notifications")
                                            .add({
                                          "content": comment,
                                          "time": DateTime.now().toString(),
                                          "title": title,
                                        }).then((data) async {
                                          showCupertinoModalPopup(
                                              context: context,
                                              builder: (context) =>
                                                  CupertinoAlertDialog(
                                                    title: Text(
                                                        "Sent Successfully"),
                                                    content: Container(
                                                      margin: EdgeInsets.only(
                                                          top: 30),
                                                      child: Text(
                                                          "Your message was sent successfully"),
                                                    ),
                                                    actions: <Widget>[
                                                      CupertinoButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: Text("OK"),
                                                      )
                                                    ],
                                                  ));
                                          setState(() {
                                            btnStatus = !btnStatus;
                                            _ctrl.clear();
                                            _ctrl2.clear();
                                          });
                                          print("comment added successfully");
                                        });
                                      } else {
                                        print("Empty fields can\'t send");
                                      }
                                    })
                                : CupertinoActivityIndicator()
                          ],
                        ),
                      )
                    ]),
                  )),
            ],
          ),
        ));
  }
}
