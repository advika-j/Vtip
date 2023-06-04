import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtip/StartingScreen.dart';
import 'package:vtip/admin/StartingScreen.dart';
import 'package:vtip/auth/login.dart';

class TempSplash extends StatefulWidget {
  @override
  _TempSplashState createState() => _TempSplashState();
}

class _TempSplashState extends State<TempSplash> {
  Future logmeout(context2) async {
    await Future.delayed(Duration(seconds: 3));
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool("admin") != null && pref.getBool("admin")) {
      print("Admin ka adda");
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => AdminStartingScreen()));
    } else if (pref.getBool("statusStudent") != null &&
        pref.getBool("statusStudent")) {
      print("User data exists in cache");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => StartingScreen()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login(" ")));
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder(
            future: logmeout(context),
            builder: (context, _data2) {
              switch (_data2.connectionState) {
                case ConnectionState.waiting:
                  return Container(
                      height: MediaQuery.of(context).size.height,
                      color: CupertinoColors.activeBlue,
                      child:
                          Center(child: Image.asset("assets/logoWhite.png", height: 250, width: 250,)));
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
                  return Container(
                      height: MediaQuery.of(context).size.height,
                      color: CupertinoColors.activeBlue,
                      child:
                          Center(child: Image.asset("assets/logoWhite.png")));
              }
            }));
  }
}
