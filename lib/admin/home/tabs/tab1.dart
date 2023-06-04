import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

FirebaseUser user;
List reports = [];

class Tab1 extends StatefulWidget {
  @override
  _Tab1State createState() => _Tab1State();
}

class _Tab1State extends State<Tab1> {
  Future getd() async {
    print("Tab 1 data is loading...");
    reports.clear();
    FirebaseAuth _auth = FirebaseAuth.instance;
    user = await _auth.currentUser();
    var data = await Firestore.instance
        .collection("reports")
        .orderBy("time", descending: true)
        .getDocuments();
    var temp = data.documents;
    for (var i = 0; i < temp.length; i++) {
      var mapTime = temp[i].data;
      var myTime = mapTime["time"];
      var currentTime = DateTime.now();
      if (myTime.toString().split(" ")[0] ==
          currentTime.toString().split(" ")[0]) {
        reports.add(mapTime);
      }
    }
    return reports;
  }

  _launchURL(_url) async {
    if (await canLaunch(_url)) {
      print(_url);
      Fluttertoast.showToast(msg: "Opening Google maps");
      await launch(_url);
    } else {
      Fluttertoast.showToast(msg: "Try again");
      throw 'Could not launch';
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        height: MediaQuery.of(context).size.height - 210,
        child: FutureBuilder(
            future: getd(),
            builder: (context, _data2) {
              switch (_data2.connectionState) {
                case ConnectionState.waiting:
                  return Center(
                    child: CupertinoActivityIndicator(),
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
                  return Center(
                    child: (_data2.data.length == 0)
                        ? Text("No Records for Today")
                        : ListView.builder(
                            itemCount: _data2.data.length,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.only(left: 20, right: 20),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: (){
                                            if(_data2.data[index]["comment"] != null){
                                              showCupertinoDialog(
                                                context: context,
                                                builder: (context){
                                                  return CupertinoAlertDialog(
                                                    title: Text("Comment"),
                                                    content: Container(
                                                      margin: EdgeInsets.only(top: 15),
                                                      child: Text(_data2.data[index]["comment"])),
                                                    actions: <Widget>[
                                                      CupertinoButton(
                                                        onPressed: ()=>Navigator.pop(context),
                                                        child: Text("Back"),
                                                      )
                                                    ],
                                                  );
                                                }
                                              );
                                            }
                                            else{
                                              Fluttertoast.showToast(msg: "No Comment found here");
                                            }
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              (index == 0)
                                                  ? Container(
                                                      margin: EdgeInsets.only(
                                                          bottom: 20),
                                                      child: Text(
                                                        "Today Reports",
                                                        style: TextStyle(
                                                            color: CupertinoColors
                                                                .activeBlue,
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold),
                                                      ),
                                                    )
                                                  : Container(),
                                              Text(
                                                "#ID${_data2.data[index]["time"].toString().substring(20, 26)}",
                                                style: TextStyle(
                                                    // color: Color(0xff0bc548),
                                                    color: CupertinoColors
                                                        .activeBlue,
                                                    fontSize: 18),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    top: 6, bottom: 3),
                                                child: Row(
                                                  children: <Widget>[
                                                    Text("Incident : ",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold)),
                                                    Text(_data2.data[index]
                                                        ["report"])
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(
                                                    top: 3, bottom: 6),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Row(
                                                      children: <Widget>[
                                                        Text("Date : ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Text(
                                                            "${_data2.data[index]['time'].toString().split(' ')[0].toString().split('-')[2]}-${_data2.data[index]['time'].toString().split(' ')[0].toString().split('-')[1]}-${_data2.data[index]['time'].toString().split(' ')[0].toString().split('-')[0]}"),
                                                      ],
                                                    ),
                                                    Container(
                                                      margin:
                                                          EdgeInsets.only(top: 6),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Text("Time : ",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          (int.parse(_data2
                                                                      .data[index]
                                                                          ['time']
                                                                      .toString()
                                                                      .split(
                                                                          ' ')[1]
                                                                      .toString()
                                                                      .split(
                                                                          ':')[0]) <
                                                                  13)
                                                              ? Text("${_data2.data[index]['time'].toString().split(' ')[1].toString().split(':')[0]} : ${_data2.data[index]['time'].toString().split(' ')[1].toString().split(':')[1]} AM")
                                                              : Text("${int.parse(_data2.data[index]['time'].toString().split(' ')[1].toString().split(':')[0]) - 12}:${_data2.data[index]['time'].toString().split(' ')[1].toString().split(':')[1]} PM")
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Text("GeoTag : ",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              200,
                                                      child: Text(
                                                        _data2.data[index]["tag"],
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                      )),
                                                ],
                                              ),
                                              (_data2.data[index]["comment"] !=
                                                      null)
                                                  ? Container(
                                                    margin: EdgeInsets.only(top: 3),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Text("Comment : ",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  200,
                                                              child: Text(
                                                                _data2.data[index]
                                                                    ["comment"],
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              )),
                                                        ],
                                                      ),
                                                    )
                                                  : SizedBox()
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                            onTap: () => {
                                                  if (Platform.isAndroid)
                                                    {
                                                      _launchURL(
                                                          "google.navigation:q=${_data2.data[index]["latitude"]},${_data2.data[index]["longitude"]}"),
                                                    }
                                                  else if (Platform.isIOS)
                                                    {
                                                      _launchURL(
                                                          "comgooglemaps://?q=${_data2.data[index]["latitude"]},${_data2.data[index]["longitude"]}"),
                                                    }
                                                },
                                            // launch(
                                            //     ),
                                            // // Navigator.pushReplac(
                                            //     context,
                                            //     MaterialPageRoute(
                                            //         builder: (context) =>
                                            //             ShowLocation(
                                            //               _data2.data[index]
                                            //                   ["report"],
                                            //               _data2.data[index]
                                            //                   ["latitude"],
                                            //               _data2.data[index]
                                            //                   ["longitude"],
                                            //             )));
                                            child: Container(
                                              child: Icon(
                                                // Icons.map
                                                IconData(0xF46D,
                                                    fontFamily:
                                                        "CupertinoIcons"),
                                                size: 45,
                                              ),
                                            )),
                                      ],
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.only(top: 20, bottom: 20),
                                      height: 0.2,
                                      color: CupertinoColors.black,
                                      width: MediaQuery.of(context).size.width,
                                    )
                                  ],
                                ),
                              );
                            }),
                  );
              }
            }),
      ),
    );
  }
}
