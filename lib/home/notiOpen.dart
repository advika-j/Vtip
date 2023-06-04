import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OpenNoti extends StatefulWidget {

  final title, content;
  OpenNoti(this.title, this.content);

  @override
  _OpenNotiState createState() => _OpenNotiState();
}

class _OpenNotiState extends State<OpenNoti> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Notifications"),
      ),
      child: Column(
        children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(left: 35,right: 35),
              margin: EdgeInsets.only(top: 130, bottom: 40),
              child: Text(
                widget.title,
                style: TextStyle(
                    color: CupertinoColors.activeBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              )),
          Container(
              padding: EdgeInsets.only(left: 35, right: 35),
              width: MediaQuery.of(context).size.width,
              child: Text(
                widget.content,
                style: TextStyle(),
              ))
        ],
      ),
    );
  }
}
