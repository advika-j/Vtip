import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtip/auth/login.dart';

class Logout extends StatefulWidget {
  @override
  _LogoutState createState() => _LogoutState();
}

class _LogoutState extends State<Logout> {
  FirebaseAuth auth = FirebaseAuth.instance;

  Future logmeout(context2) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool("admin", false);
    print("Removed Admin preference");
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context2) => Login(" ")));
  }

  @override
  void initState() {
    auth.signOut();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder(
            future: logmeout(context),
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
                  return CupertinoActivityIndicator(
                    radius: 20,
                  );
              }
            }));
  }
}
