import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vtip/admin/home/myreports.dart';
import 'package:vtip/home/notiOpen.dart';

class Notifications extends StatefulWidget {
  static const routeName = '/extractArguments';
  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 80,
          padding: EdgeInsets.only(bottom: 10),
          alignment: Alignment.bottomCenter,
          width: MediaQuery.of(context).size.width,
          color: Color(0xffF8F8F8),
          child: Text(
            "Notifications",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
        ),
        Container(
          alignment: Alignment.topCenter,
          height: MediaQuery.of(context).size.height - 90,
          child: StreamBuilder(
            stream: Firestore.instance.collection("notifications").orderBy("time", descending : true).snapshots(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
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
                case ConnectionState.done:
                  return Center(child: Text("Loading"));
                  break;
                case ConnectionState.active:
                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = snapshot.data.documents[index];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        OpenNoti(ds["title"], ds["content"]),
                                  ),
                                  (Route<dynamic> route) => true);
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 20, bottom: 20),
                              child: Row(
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                100,
                                            margin: EdgeInsets.only(
                                                top: 6, bottom: 6),
                                            child: Text(
                                              ds["title"],
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: CupertinoColors
                                                      .activeBlue,
                                                  fontSize: 20),
                                            ),
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "Date : ",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Container(
                                                child: Text(
                                                  " ${ds['time'].toString().split(' ')[0].toString().split('-')[2]}-${ds['time'].toString().split(' ')[0].toString().split('-')[1]}-${ds['time'].toString().split(' ')[0].toString().split('-')[0]}",
                                                  style: TextStyle(
                                                      color: Colors.black54),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                          margin: EdgeInsets.only(top: 5),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              80,
                                          child: Text(
                                            ds["content"],
                                            maxLines: 2,
                                            style: TextStyle(),
                                          ))
                                    ],
                                  ),
                                  Icon(
                                    CupertinoIcons.right_chevron,
                                    color: CupertinoColors.activeBlue,
                                    size: 30,
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  );
              }
            },
          ),
        ),
      ],
    ));
  }
}
