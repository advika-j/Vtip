import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';
import 'StartingScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

FirebaseUser user;
var comment;
GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
bool _autoValidate, btnStatus;

class Report extends StatefulWidget {
  final name, id;
  Report({this.name, this.id});
  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    btnStatus = true;
    _autoValidate = false;
    //  http.get(
    //       "https://us-central1-v-tip-project.cloudfunctions.net/sendNotificationToAdmin/$type/${currentLocation.latitude}/${currentLocation.longitude}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("Report"),
        ),
        child: Scaffold(
            key: _scaffoldKey,
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: SingleChildScrollView(
                child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 120),
                    child: Column(children: <Widget>[
                      Image.asset(
                        "assets/logo.png",
                        height: 200,
                        width: 200,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Text(widget.name,
                            style: TextStyle(
                                color: CupertinoColors.activeBlue,
                                fontSize: 40)),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Text("Reported!",
                            style: TextStyle(
                                color: CupertinoColors.activeBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 40)),
                      ),
                      Form(
                        key: _formKey,
                        autovalidate: _autoValidate,
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(left: 18, top: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.black26)),
                              height: 200,
                              margin: EdgeInsets.all(20),
                              child: TextFormField(
                                validator: (data) {
                                  if (data == null) {
                                    return "Empty report cant be sent";
                                  } else {
                                    return null;
                                  }
                                },
                                initialValue: null,
                                style: TextStyle(
                                    color: Colors.black54,
                                    wordSpacing: 4,
                                    letterSpacing: 1),
                                decoration: InputDecoration(
                                    labelStyle: TextStyle(color: Colors.red),
                                    border: InputBorder.none,
                                    hintText:
                                        "If you want to explain the incident,\nPlease write here (Optional)",
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
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 30),
                              child: (btnStatus)
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
                                        setState(() {
                                          _autoValidate = true;
                                        });
                                        if (_formKey.currentState.validate()) {
                                          setState(() {
                                            btnStatus = !btnStatus;
                                          });
                                          await Firestore.instance
                                              .collection("reports")
                                              .document(widget.id)
                                              .updateData({
                                            "comment": comment
                                          }).then((data) {
                                            print("comment added successfully");
                                          });
                                          await http.get(
                                              "https://us-central1-varun-time.cloudfunctions.net/sendNotification/${widget.name}");
                                          _scaffoldKey.currentState
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                "Report sent Successfully"),
                                          ));
                                          Navigator.pop(context);
                                        }
                                      })
                                  : CupertinoActivityIndicator(),
                            ),
                          ],
                        ),
                      )
                    ])),
              ),
            )));
  }
}
