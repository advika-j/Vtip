import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

List myReports = [];
http.Response name;
var temp;
List<String> tags = [];

class MyReports extends StatefulWidget {
  @override
  _MyReportsState createState() => _MyReportsState();
}

class _MyReportsState extends State<MyReports> {
  getLocation() async {
    var location = new Location();
    var currentLocation = await location.getLocation();
    print(
        "Latitude : ${currentLocation.latitude}, longitude : ${currentLocation.longitude}");
  }

  // Future test() async {
  //   bool result;
  //   SharedPreferences pref = await SharedPreferences.getInstance();
  //   var docQuery = await Firestore.instance
  //       .collection("reports")
  //       .orderBy("time", descending: true)
  //       .getDocuments();
  //   var docList = docQuery.documents;
  //   docList.forEach((f) async {
  //     if (f["email"].toString() == pref.getString("email").toString()) {
  //       myReports.add(f);
  //       await http
  //           .get(
  //               "http://localhost:5001/v-tip-project/us-central1/checkGeotag/${f["latitude"]}/${f["longitude"]}")
  //           .then((data) {
  //         tags.add(data.body);
  //         print("*********${data.body}");
  //         print(
  //             "defined tags -------------- ${data.body}, ${f['latitude']}/${f["longitude"]}");
  //       });
  //       print("loop");
  //     }
  //     result = true;
  //     return myReports;
  //   });
  //   checkme() async {
  //     await Future.delayed(Duration(seconds: 1));
  //     if (!result) {
  //       print("tried to check");
  //       checkme();
  //     } else
  //       return myReports;
  //   }

  //   var data = await checkme();
  // }

  Future getData() async {
    print("getdata is running");
    myReports.clear();
    SharedPreferences pref = await SharedPreferences.getInstance();
    await Firestore.instance
        .collection("reports")
        .orderBy("time", descending: true)
        .getDocuments()
        .then((onValue) async {
      var eachDoc = onValue.documents;
      eachDoc.forEach((f) => {
            if (f["email"].toString() == pref.getString("email").toString())
              {
                myReports.add(f),
              }
          });
    });
    return myReports;
  }

  @override
  void dispose() {
    print("reports disposed");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 80,
          padding: EdgeInsets.only(bottom: 12),
          alignment: Alignment.bottomCenter,
          width: MediaQuery.of(context).size.width,
          color: Color(0xffF8F8F8),
          child: Text(
            "My Reports",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        Container(
       
          height: MediaQuery.of(context).size.height - 110,
          child: FutureBuilder(
              future: getData(),
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
                        return Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(right: 30, left: 18),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "#ID${_data2.data[index]["time"].toString().substring(20, 26)}",
                                        style: TextStyle(
                                            // color: Color(0xff0bc548),
                                            color: CupertinoColors.activeBlue,
                                            fontSize: 18),
                                      ),
                                      Container(
                                        margin:
                                            EdgeInsets.only(top: 6, bottom: 3),
                                        child: Row(
                                          children: <Widget>[
                                            Text("Incident : ",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(_data2.data[index]["report"])
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin:
                                            EdgeInsets.only(top: 3, bottom: 6),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Text("Date : ",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                    "${_data2.data[index]['time'].toString().split(' ')[0].toString().split('-')[2]}-${_data2.data[index]['time'].toString().split(' ')[0].toString().split('-')[1]}-${_data2.data[index]['time'].toString().split(' ')[0].toString().split('-')[0]}"),
                                              ],
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 6),
                                              child: Row(
                                                children: <Widget>[
                                                  Text("Time : ",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  (int.parse(_data2.data[index]
                                                                  ['time']
                                                              .toString()
                                                              .split(' ')[1]
                                                              .toString()
                                                              .split(':')[0]) <
                                                          13)
                                                      ? Text(
                                                          "${_data2.data[index]['time'].toString().split(' ')[1].toString().split(':')[0]} : ${_data2.data[index]['time'].toString().split(' ')[1].toString().split(':')[1]} AM")
                                                      : Text(
                                                          "${int.parse(_data2.data[index]['time'].toString().split(' ')[1].toString().split(':')[0]) - 12}:${_data2.data[index]['time'].toString().split(' ')[1].toString().split(':')[1]} PM")
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
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(
                                              width: 200,
                                              child: Text(
                                                _data2.data[index]['tag'],
                                                overflow: TextOverflow.ellipsis,
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // Container(
                                  //     child: GestureDetector(
                                  //   onTap: () => Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(
                                  //           builder: (context) => ShowLocation(
                                  //               // id:"#ID${_data2.data[index]["time"].toString().substring(23, 28)}",
                                  //               // incident:_data2.data[index]["report"].toString(),
                                  //               _data2.data[index]["latitude"],
                                  //             _data2.data[index]["longitude"]
                                  //               )
                                  //               ),),
                                  //   child: Icon(
                                  //     CupertinoIcons.location,
                                  //     color: CupertinoColors.activeBlue,
                                  //     size: 30,
                                  //   ),
                                  // )),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 20, bottom: 20),
                              height: 0.2,
                              color: CupertinoColors.black,
                              width: MediaQuery.of(context).size.width,
                            )
                          ],
                        );
                      },
                    );
                }
              }),
        ),
      ],
    );
  }
}
