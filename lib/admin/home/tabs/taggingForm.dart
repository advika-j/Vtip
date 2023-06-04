import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vtip/auth/signup.dart';
import 'package:http/http.dart' as http;

final _formKey = GlobalKey<FormState>();
List markers = [];
var email;
double val;
bool btnStatus;

class TaggingFormSet extends StatefulWidget {
  final latitude, longitude, email;
  TaggingFormSet(this.latitude, this.longitude, this.email);
  @override
  _TaggingFormSetState createState() => _TaggingFormSetState();
}

class _TaggingFormSetState extends State<TaggingFormSet> {
  GoogleMapController _mapController;

  void initState() {
    btnStatus = true;
    markers.clear();
    val = 5.0;
    print(val.toInt().toString());
    print(widget.latitude);
    print(widget.longitude);
    print(widget.email);
    markers.add(Marker(
        onTap: () {
          print("Pin is tapped");
          Fluttertoast.showToast(msg: "Set your pin");
        },
        markerId: MarkerId("value"),
        position: LatLng(widget.latitude, widget.longitude)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Set Geo Point"),
      ),
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(top: 100),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(
                                  left: 30, top: 30, right: 30, bottom: 60),
                              child: TextFormField(
                                decoration:
                                    InputDecoration(hintText: "Area Name"),
                                validator: (data) {
                                  if (data.isEmpty) {
                                    return "Name can\'t be Empty";
                                  } else {
                                    return null;
                                  }
                                },
                                onChanged: (data) {
                                  name = data;
                                },
                              ),
                            ),
                            Container(
                              height: 300,
                              margin: EdgeInsets.only(bottom: 20),
                              child: GoogleMap(
                                zoomGesturesEnabled: true,
                                initialCameraPosition: CameraPosition(
                                    zoom: 18,
                                    target: LatLng(
                                        widget.latitude, widget.longitude)),
                                onMapCreated: (_mapCtrl) {
                                  _mapController = _mapCtrl;
                                },
                                markers: Set.from(markers),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Radius (Meters) : "),
                                Container(
                                    margin: EdgeInsets.all(6),
                                    child: Text(val.toInt().toString())),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("0 Mts   "),
                                CupertinoSlider(
                                  value: val,
                                  max: 50.0,
                                  onChanged: (data) {
                                    print(data.toInt().toString());
                                    setState(() {
                                      val = data;
                                    });
                                  },
                                ),
                                Text("   50 Mts")
                              ],
                            ),
                            Container(
                                margin: EdgeInsets.only(top: 60),
                                child: (btnStatus)
                                    ? CupertinoButton(
                                        color: CupertinoColors.activeBlue,
                                        onPressed: () {
                                          if (_formKey.currentState
                                              .validate()) {
                                            Firestore.instance
                                                .collection(
                                                    "geotags/${widget.email}/tags")
                                                .add({
                                              "center": {
                                                "lat": widget.latitude,
                                                "lng": widget.longitude
                                              },
                                              "time": DateTime.now().toString(),
                                              "name": name,
                                              "radius": val.toInt()
                                            }).then((onValue) async {
                                              await Firestore.instance
                                                  .collection(
                                                      "geotags/tags/tags")
                                                  .add({
                                                "lat": widget.latitude,
                                                "lng": widget.longitude,
                                                "radius": val.toInt(),
                                                "name": name,
                                                "email": widget.email,
                                                "time":
                                                    DateTime.now().toString()
                                              });
                                              await http.get(
                                                  "https://us-central1-v-tip-project.cloudfunctions.net/adminGeotagAdded/$name/${widget.latitude}/${widget.longitude}/${val.toInt()}");
                                              Fluttertoast.showToast(
                                                  msg:
                                                      "Geo Tag Added successfully");
                                              Navigator.pop(context);
                                            });
                                          }
                                        },
                                        child: Text(
                                          "Set Geo Point",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )
                                    : CupertinoActivityIndicator())
                          ],
                        ))),
                Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 30, bottom: 30),
                  child: GestureDetector(
                    onTap: () {
                      var templng = LatLng(widget.latitude, widget.longitude);
                      _mapController
                          .animateCamera(CameraUpdate.newLatLng(templng));
                    },
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: CupertinoColors.activeBlue,
                      ),
                      child: Icon(Icons.gps_fixed, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
