import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vtip/StartingScreen.dart';
import 'package:vtip/admin/login.dart';
import 'signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

var email, password, forgotEmail;
bool pass, _autoValidate, chinnaValidate, btnStatus;
TextEditingController pass1, pass2;

class Login extends StatefulWidget {
  final email;
  Login(this.email);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  getEmail(email, password) async {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(email)) {
      await Firestore.instance.document("users/$email").get().then((mydata) {
        var userEmail = mydata["email"];
        print(userEmail);
        check(userEmail, password);
      }).catchError((onError) {
        setState(() {
          btnStatus = !btnStatus;
        });
        Fluttertoast.showToast(msg: "Please check your credentials");
        print(onError);
      });
    } else {
      check(email, password);
    }
  }

  check(String email, String password) async {
    _firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((user) async {
      if (user.user.isEmailVerified) {
        print("User all set to rock");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await Firestore.instance
            .collection("users")
            .getDocuments()
            .then((docs) {
          docs.documents.forEach((dr) => {
                if (dr["email"] == email)
                  {
                    prefs.setBool("statusStudent", true),
                    prefs.setString("id", dr.data["id"]),
                    prefs.setString("name", dr.data["name"]),
                    prefs.setString("email", user.user.email),
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => StartingScreen()),
                        (Route<dynamic> route) => false),
                  }
              });
        });
        // DocumentSnapshot dr =
        //     await Firestore.instance.document("users/${user.user.email}").get();
      } else {
        setState(() {
          btnStatus = !btnStatus;
        });
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('Your email is not verified'),
          action: SnackBarAction(
            label: "Send Email",
            onPressed: () {
              user.user.sendEmailVerification().then((onValue) {
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text("Email sent to $email"),
                ));
              });
            },
          ),
          duration: Duration(seconds: 8),
        ));
      }
    }).catchError((onError) {
      setState(() {
        btnStatus = !btnStatus;
      });
      print(onError);
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Invalid Credentials"),
      ));
    });
  }

  forgotEmailCheck() async {
    _firebaseAuth.sendPasswordResetEmail(email: forgotEmail).then((onValue) {
      print("Forgot mail sent to $forgotEmail");
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Email sent successfully"),
      ));
      // Fluttertoast.showToast(msg: "Email sent successfully");
    }).catchError((onError) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Email is not Registered"),
        action: SnackBarAction(
          label: "Register",
          onPressed: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Signup())),
        ),
      ));
      // Fluttertoast.showToast(msg: "Email is not Registered");
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    btnStatus = true;
    pass = true;
    _autoValidate = chinnaValidate = false;
    forgotEmail = "";
    print(widget.email);
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
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.only(left: 30, right: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () => showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Text("data");
                    }),
                child: Container(
                    margin: EdgeInsets.only(top: 60),
                    child: Image.asset(
                      "assets/logo.png",
                      height: 150,
                      width: 150,
                    )),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
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
                              alignLabelWithHint: true,
                              hintText: "Email / User ID"),
                          validator: (value) {
                            Pattern pattern =
                                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                            RegExp regex = RegExp(pattern);
                            if (value.isEmpty) {
                              return 'This field can\'t be empty';
                            } else {
                              email = value;
                              return null;
                            }
                          },
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 18),
                          child: TextFormField(
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
                            obscureText: pass,
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
                                      setState(() {
                                        _autoValidate = true;
                                      });
                                      if (_formKey.currentState.validate()) {
                                        setState(() {
                                          btnStatus = !btnStatus;
                                        });
                                        getEmail(email, password);
                                      }
                                    })
                                : CupertinoActivityIndicator(
                                    radius: 10,
                                  )),

                        //Forgot password
                        Container(
                            margin: EdgeInsets.only(top: 15),
                            child: GestureDetector(
                              onTap: () => showCupertinoDialog(
                                  context: context,
                                  builder: (context) {
                                    return CupertinoAlertDialog(
                                      title: Text("Forgot Password"),
                                      content: Form(
                                        key: _forgotFormKey,
                                        autovalidate: chinnaValidate,
                                        child: Container(
                                          height: 50,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                margin:
                                                    EdgeInsets.only(top: 18),
                                                child: CupertinoTextField(
                                                  placeholder:
                                                      "Enter your Email ID",
                                                  onChanged: (data) {
                                                    forgotEmail = data;
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      actions: <Widget>[
                                        CupertinoButton(
                                            child: Text("Cancel"),
                                            onPressed: () =>
                                                Navigator.pop(context)),
                                        CupertinoButton(
                                            child: Text("Send Email"),
                                            onPressed: () {
                                              Pattern pattern =
                                                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                              RegExp regex = RegExp(pattern);
                                              if (!regex
                                                  .hasMatch(forgotEmail)) {
                                                _scaffoldKey.currentState
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        "Email is not valid"),
                                                    duration:
                                                        Duration(seconds: 3),
                                                  ),
                                                );
                                              } else {
                                                forgotEmailCheck();
                                              }
                                            }),
                                      ],
                                      // actions: <Widget>[
                                      //   CupertinoDialogAction(
                                      //     isDefaultAction: true,
                                      //     child: Text("Yes"),
                                      //   ),
                                      //   CupertinoDialogAction(
                                      //     child: Text("No"),
                                      //   )
                                      // ],
                                    );
                                  }),
                              child: Text(
                                "Forgot Password",
                                style: TextStyle(
                                    color: CupertinoColors.activeBlue,
                                    fontWeight: FontWeight.bold),
                              ),
                            )),
                        Container(
                          margin: EdgeInsets.only(top: 60),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Still without account? ",
                                style: TextStyle(
                                  color: CupertinoColors.activeBlue,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Signup())),
                                child: Container(
                                  child: Text(
                                    "Sign Up",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  decoration: BoxDecoration(
                                      border: Border(
                                    bottom: BorderSide(
                                      color: CupertinoColors.activeBlue,
                                      width: 3.0,
                                    ),
                                  )),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 50, bottom: 20),
                          height: 0.5,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.black38,
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 20),
                          child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AdminLogin()));
                              },
                              child: Text(
                                "I am Admin",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: CupertinoColors.activeBlue),
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
