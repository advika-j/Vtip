import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Tab2 extends StatefulWidget {
  @override
  _Tab2State createState() => _Tab2State();
}

class _Tab2State extends State<Tab2> {
  getLocation() async {
    var location = new Location();
    var currentLocation = await location.getLocation();
    print(
        "Latitude : ${currentLocation.latitude}, longitude : ${currentLocation.longitude}");
  }

  @override
  void initState() {
    // getLocation();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: "https://v-tip-project.firebaseapp.com"),
    );
  }
}
