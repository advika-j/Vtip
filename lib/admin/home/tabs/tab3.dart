import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtip/admin/home/tabs/taggingForm.dart';

var names = ["New Lake", "Students Club", "Canteen", "Temple"];
var currentLocation, email;
List tagList = [];

class Tab3 extends StatefulWidget {
  // tabData(){
  //   var data = Firestore().collection("geotags/").document("")
  // }
  @override
  _Tab3State createState() => _Tab3State();
}

class _Tab3State extends State<Tab3> {
  getLocation() async {
    print("Tab3 data is loading...");
    tagList.clear();
    SharedPreferences pref = await SharedPreferences.getInstance();
    email = pref.getString("email");
    var database = await Firestore.instance
        .collection("geotags/$email/tags")
        .getDocuments();
    var basedata = database.documents;
    var location = new Location();
    currentLocation = await location.getLocation();
    return basedata;
  }

  getPermissions() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.locationWhenInUse);
    print(permission);
    if (permission.toString() != "PermissionStatus.granted") {
      await Location().getLocation();
    }
    // if(permission.toString() == "PermissionStatus.unknown"){
    //   print("asking permissions");
    //       Map<PermissionGroup, PermissionStatus> permissions =
    //     await PermissionHandler()
    //         .requestPermissions([PermissionGroup.calendar]);
    // }
  }

  @override
  void initState() {
    getPermissions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;
    return CupertinoPageScaffold(
        child: Stack(alignment: Alignment.bottomRight, children: <Widget>[
      Container(
          height: MediaQuery.of(context).size.height - 110,
          child: FutureBuilder(
              future: getLocation(),
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
                              //Content
                              Container(
                                padding: EdgeInsets.only(
                                    left: 30, right: 30, top: 10, bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                            margin: EdgeInsets.only(
                                                top: 3, bottom: 3),
                                            child: Text(
                                              _data2.data[index]["name"],
                                              style: TextStyle(
                                                  color: CupertinoColors
                                                      .activeBlue,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            )),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              100,
                                          child: Text(
                                            "Location : ${_data2.data[index]['center']['lat']}, ${_data2.data[index]['center']['lng']}",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              "Radius : ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(_data2.data[index]['radius']
                                                .toString())
                                          ],
                                        )
                                      ],
                                    ),
                                    GestureDetector(
                                        onTap: () async {
                                          showCupertinoDialog(
                                              context: context,
                                              builder: (context) {
                                                return CupertinoAlertDialog(
                                                  title: Text("Delete Geotag"),
                                                  content: Container(
                                                    margin: EdgeInsets.only(
                                                        top: 15),
                                                    child: Text(
                                                        "Once you delete ${_data2.data[index]['name']} Geotag you can\'t retive it back"),
                                                  ),
                                                  actions: <Widget>[
                                                    GestureDetector(
                                                      onTap: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child:
                                                          CupertinoDialogAction(
                                                        child: Text(
                                                          "Cancel",
                                                          style: TextStyle(
                                                              color: CupertinoColors
                                                                  .activeBlue),
                                                        ),
                                                      ),
                                                    ),
                                                    CupertinoDialogAction(
                                                      isDefaultAction: true,
                                                      child: GestureDetector(
                                                        onTap: () => Firestore
                                                            .instance
                                                            .collection(
                                                                "geotags/$email/tags")
                                                            .getDocuments()
                                                            .then((onValue) {
                                                          var doc =
                                                              onValue.documents;
                                                          var id = doc[index]
                                                              .documentID;
                                                          Firestore.instance
                                                              .collection(
                                                                  "geotags/$email/tags")
                                                              .document(id)
                                                              .delete()
                                                              .then((onv) {
                                                            setState(() {});
                                                            Navigator.pop(
                                                                context);
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "GeoTag removed Successfully");
                                                          });
                                                        }),
                                                        child: Text(
                                                          "Delete",
                                                          style: TextStyle(
                                                              color: CupertinoColors
                                                                  .destructiveRed),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              });
                                        },
                                        child: Icon(CupertinoIcons.delete))
                                  ],
                                ),
                              ),

                              Container(
                                height: 0.2,
                                width: _width,
                                color: CupertinoColors.black,
                              ),
                            ],
                          );
                        });
                }
              })),
      GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    // AdminRecords()
                    TaggingFormSet(currentLocation.latitude,
                        currentLocation.longitude, email))),
        child: Container(
          margin: EdgeInsets.only(right: 30),
          decoration: BoxDecoration(
              color: CupertinoColors.activeBlue,
              borderRadius: BorderRadius.circular(60)),
          height: 60,
          width: 60,
          child: Icon(
            CupertinoIcons.add,
            color: CupertinoColors.white,
            size: 45,
          ),
        ),
      )
    ]));
  }
}
