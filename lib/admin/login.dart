import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vtip/admin/StartingScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtip/auth/login.dart';

var email, password;
bool pass, _autoValidate, chinnaValidate;
TextEditingController pass1, pass2;
bool status, btnStatus;

class AdminLogin extends StatefulWidget {
  @override
  _AdminLoginState createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  check(String email, String password) async {
    DocumentSnapshot dr2 = await Firestore.instance
        .document("admin/$email")
        .get()
        .then((dr) async {
      if (dr.data["pass"] == password) {
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setBool("admin", true);
        pref.setString("email", email);
        print("Data stored in  shared preference :)");
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => AdminStartingScreen()),
            (Route<dynamic> route) => false);
      } else {
        print("Please check your password");
        setState(() {
          btnStatus = !btnStatus;
        });
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text("Please check your password")));
      }
    }).catchError((onError) {
      setState(() {
        btnStatus = !btnStatus;
      });
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text("Email is not Registered with us")));
    });
  }

  @override
  void initState() {
    btnStatus = true;
    pass = true;
    _autoValidate = chinnaValidate = false;
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  final _forgotFormKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 30, right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                    margin: EdgeInsets.only(top: 50),
                    child: Icon(
                      CupertinoIcons.left_chevron,
                      size: 35,
                      color: CupertinoColors.activeBlue,
                    )),
              ),
              Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Image.asset(
                    "assets/logo.png",
                    height: 150,
                    width: 150,
                  )),
              Container(
                margin: EdgeInsets.only(top: 30),
                child: Text(
                  "Hello!",
                  style: TextStyle(
                      color: CupertinoColors.activeBlue,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Text(
                  "Welcome to V-TIP",
                  style: TextStyle(
                      color: CupertinoColors.activeBlue,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
              ),

              //Form data starts here
              Container(
                margin: EdgeInsets.only(top: 60),
                child: Form(
                    key: _formKey,
                    autovalidate: _autoValidate,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                              alignLabelWithHint: true, hintText: "Admin ID"),
                          validator: (value) {
                            Pattern pattern =
                                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                            RegExp regex = RegExp(pattern);
                            if (!regex.hasMatch(value)) {
                              return 'Enter Valid Email';
                            } else {
                              email = value;
                              return null;
                            }
                          },
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 18),
                          child: TextFormField(
                            obscureText: pass,
                            decoration: InputDecoration(
                              alignLabelWithHint: true,
                              hintText: "Password",
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      pass = !pass;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.remove_red_eye,
                                    color: (pass) ? Colors.grey : Colors.black,
                                  )),
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'This field can\'t be null';
                              } else {
                                password = value;
                                return null;
                              }
                            },
                          ),
                        ),
                        Container(
                            width: 180,
                            height: 50,
                            margin: EdgeInsets.only(top: 50, bottom: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100)),
                            child: (btnStatus)
                                ? CupertinoButton(
                                    color: CupertinoColors.activeBlue,
                                    child: Text(
                                      'Login',
                                      style: TextStyle(
                                        color: CupertinoColors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () {
                                      _autoValidate = true;
                                      if (_formKey.currentState.validate()) {
                                        setState(() {
                                          btnStatus = !btnStatus;
                                        });
                                        check(email, password);
                                      }
                                    })
                                : CupertinoActivityIndicator()),

                        //Forgot password
                        Container(
                          margin: EdgeInsets.only(top: 15, bottom: 25),
                          child: GestureDetector(
                              onTap: () => showCupertinoDialog(
                                  context: context,
                                  builder: (context) {
                                    return CupertinoAlertDialog(
                                      title: Text("Forgot Password"),
                                      content: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                              margin: EdgeInsets.only(top: 20),
                                              child: Text(
                                                  "Please Contact : hello@vtip.ml")),
                                          // CupertinoButton(
                                          //   onPressed: () =>
                                          //       Navigator.pop(context),
                                          //   child: Text("cancel"),
                                          // )
                                        ],
                                      ),
                                      actions: <Widget>[
                                        GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: CupertinoDialogAction(
                                            isDefaultAction: true,
                                            child: Text("Cancel"),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: CupertinoColors.activeBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                        )
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
