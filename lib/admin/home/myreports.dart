import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

FirebaseUser user;
var items_number, temp, dir2, req, fpath;
http.Client client;
bool imageShow;

class MyReports extends StatefulWidget {
  @override
  _MyReportsState createState() => _MyReportsState();
}

class _MyReportsState extends State<MyReports> {
  // Future getUserdata() async {
  //   print("Admin reports are loading...");
  //   FirebaseUser user = await FirebaseAuth.instance.currentUser();
  //   // user = await _auth.currentUser();
  //   var data = await Firestore.instance
  //       .collection("reports")
  //       .orderBy("time", descending: true)
  //       .getDocuments();
  //   temp = data.documents;
  //   return temp;
  // }

  _launchURL(_url) async {
    var url = _url;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  downme() async {
    Fluttertoast.showToast(msg: "report is being generated");
    if (Platform.isIOS) {
      var pathoo = await getApplicationDocumentsDirectory();
      print("file path :${pathoo.path}");
      assert(Directory(pathoo.path).existsSync());
      FlutterDownloader.enqueue(
              url:
                  "https://us-central1-v-tip-project.cloudfunctions.net/generateReport",
              savedDir: "${pathoo.path}",
              fileName: "generateReport.xlsx",
              showNotification: true,
              openFileFromNotification: true)
          .then((onValue) {
        OpenFile.open("${pathoo.path}/generateReport.xlsx").then((success) {
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "File downloaded");
          print("opening with success $success");
        }).catchError((onError) {
          Navigator.pop(context);
          fpath = "${pathoo.path}/report.xlsx";
          Fluttertoast.showToast(
              msg: "Something went wrong. File not downloaded");
          print("error : $onError");
        });
      });
    } else {
      var pathoo = await getApplicationDocumentsDirectory();
      assert(Directory(pathoo.path).existsSync());
      print("its android rey");
      FlutterDownloader.enqueue(
              url:
                  "https://us-central1-v-tip-project.cloudfunctions.net/generateReport",
              savedDir: "${pathoo.path}",
              fileName: "generateReport.xlsx",
              showNotification: true,
              openFileFromNotification: true)
          .then((onValue) {
        Navigator.pop(context);
        OpenFile.open("${pathoo.path}/generateReport.xlsx").then((success) {
          Fluttertoast.showToast(msg: "File downloaded");
          print("opening with success $success");
        }).catchError((onError) {
          Fluttertoast.showToast(
              msg: "Something went wrong. File not downloaded");
          print("error : $onError");
        });
      }).catchError((onError) {
        Navigator.pop(context);
        print("Main error $onError");
      });
    }

    // ImageDownloader.downloadImage(
    //         "https://firebasestorage.googleapis.com/v0/b/v-tip-project.appspot.com/o/VTip-Logo%202.jpg?alt=media&token=675178b3-d1d1-4649-b036-7dfb11668098")
    //     .catchError((error) async {
    //   if (error is PlatformException) {
    //     var pathoo = await getApplicationDocumentsDirectory();
    //     print(pathoo);
    //     var path = "$pathoo/image.png";
    //     if (error.code == "404") {
    //       print("Not Found Error.");
    //     } else if (error.code == "unsupported_file") {
    //       print("UnSupported FIle Error.");
    //       path = error.details["unsupported_file_path"];
    //     }
    //   }
    // });
  }

  launchMap() async {
    var lat = "47.6";
    var long = "-122.3";
    var mapSchema = 'geo:$lat,$long';
    if (await canLaunch(mapSchema)) {
      await launch(mapSchema);
    } else {
      throw 'Could not launch $mapSchema';
    }
  }
  // expandMe() async {
  //   if (temp.le)
  //     setState(() {
  //       // print("admin reports called set state");
  //       // await Future.delayed(Duration(seconds: 2));
  //       items_number += 5;
  //     });
  // }

  tempDat() async {
    var mydata = await Firestore.instance
        .collection("reports")
        .orderBy("time", descending: true)
        .getDocuments();
    return mydata.documents;
  }

  getPermision() async {
    // Map<PermissionGroup, PermissionStatus> permissions2 =
    //     await PermissionHandler().requestPermissions([PermissionGroup.sensors]);
    // print("permissions2: $permissions2");
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    print("permission : $permission");
  }

  @override
  void initState() {
    imageShow = true;
    print("my reports called at init state");
    items_number = 5;
    // getUserdata();
    // getPermision();
    // getLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(

          height: 80,
          padding: EdgeInsets.only(bottom: 10, left: 30),
          alignment: Alignment.bottomLeft,
          width: MediaQuery.of(context).size.width,
          color: CupertinoColors.activeBlue,
          child: Text(
            "Reports",
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 22, color: Colors.white),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 30),
          height: MediaQuery.of(context).size.height - 120,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: <Widget>[
              FutureBuilder(
                  // future: getUserdata(),
                  future: tempDat(),
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
                        return ListView.builder(
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
                                        onTap: () {
                                          if (_data2.data[index]["comment"] !=
                                              null) {
                                            showCupertinoDialog(
                                                context: context,
                                                builder: (context) {
                                                  return CupertinoAlertDialog(
                                                    title: Text("Comment"),
                                                    content: Container(
                                                        margin: EdgeInsets.only(
                                                            top: 15),
                                                        child: Text(
                                                            _data2.data[index]
                                                                ["comment"])),
                                                    actions: <Widget>[
                                                      CupertinoButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: Text("Back"),
                                                      )
                                                    ],
                                                  );
                                                });
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: "No Comment found here");
                                          }
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              "#ID${_data2.data[index]["time"].toString().substring(20, 26)}",
                                              style: TextStyle(
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
                                                Text("Location : ",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            200,
                                                    child: Text(
                                                      _data2.data[index]['tag'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )),
                                              ],
                                            ),
                                            (_data2.data[index]["comment"] !=
                                                    null)
                                                ? Container(
                                                    margin:
                                                        EdgeInsets.only(top: 3),
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
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          child: Icon(
                                            // Icons.map
                                            IconData(0xF46D,
                                                fontFamily: "CupertinoIcons"),
                                            size: 45,
                                          ),
                                        ),
                                      )
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
                          },
                        );
                      // NotificationListener<ScrollNotification>(
                      //   onNotification: (scrollNotification) {
                      //     if (scrollNotification.metrics.pixels ==
                      //         scrollNotification.metrics.maxScrollExtent) {
                      //       expandMe();
                      //       setState(() {
                      //         // print("admin reports called set state");
                      //         // await Future.delayed(Duration(seconds: 2));
                      //         items_number += 5;
                      //       });
                      //     }
                      //   },
                      //   child:
                      // );
                    }
                  }),
              GestureDetector(
                onTap: () async {
                  showCupertinoDialog(
                      context: context,
                      builder: (context) {
                        return Center(
                          child: CupertinoActivityIndicator(),
                        );
                      });
                  downme();
                  // await getApplicationDocumentsDirectory().then((dir) async {
                  //   print(dir);
                  //   // Directory('${dir.path}/CapturedImages').create(recursive: true);
                  //   Fluttertoast.showToast(msg: "Reports are downloading now");
                  //   Dio().get("http://varunvorld.ml/v.jpg",).then((onValue){
                  //     print("status : ${onValue}");
                  //   }).catchError((onError){
                  //     print("Onerror : $onError");
                  //   });
                  // }),
                  // FlutterDownloader.enqueue(
                  //   url:
                  //   "https://firebasestorage.googleapis.com/v0/b/v-tip-project.appspot.com/o/VTip-Logo%202.jpg?alt=media&token=675178b3-d1d1-4649-b036-7dfb11668098",
                  //       // "https://us-central1-v-tip-project.cloudfunctions.net/generateReport",
                  //   savedDir: "/",
                  //   fileName: "V-Tip Report",
                  // ),
                },
                child: Container(
                  margin: EdgeInsets.only(right: 30, bottom: 60),
                  decoration: BoxDecoration(
                      color: CupertinoColors.activeBlue,
                      borderRadius: BorderRadius.circular(60)),
                  height: 60,
                  width: 60,
                  child: Icon(
                    CupertinoIcons.down_arrow,
                    color: CupertinoColors.white,
                    size: 45,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
