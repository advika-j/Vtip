import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vtip/tempSplash.dart';
import 'package:splashscreen/splashscreen.dart';

void main() {
  // This app is designed only to work vertically, so we limit
  // orientations to portrait up and down.
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(CupertinoApp(
    debugShowCheckedModeBanner: false,
    home: TempSplash(),
  ));
}

class MySplash extends StatefulWidget {
  @override
  _MySplashState createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 3,
      navigateAfterSeconds: TempSplash(),
      image: Image.asset(
        "assets/logoWhite.png",
        height: 250,
        width: 250,
      ),
      backgroundColor: CupertinoColors.activeBlue,
      styleTextUnderTheLoader: TextStyle(),
      photoSize: 100.0,
      loaderColor: CupertinoColors.white,
    );
  }
}
