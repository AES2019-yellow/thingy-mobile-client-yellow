/*
 * File: /loginRegShared.dart
 * Project: Thingy-mobile-client-yellow
 * File Created: Thu, 12th December 2019 12:27:48 am
 * Author: Yi Zhang (yi.zhang@unifr.ch)
 * -----
 * Copyright 2019 - 2019 AES-Unifr, AES2019-Yellow
 */
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';

const LOGIN_API = "http://127.0.0.1:3000/login/";
const REG_API = "http://127.0.0.1:3000/register/";
class Login extends StatefulWidget {
  @override
  _LoginState createState()=> _LoginState();
}

enum LoginStatus { notLogIn, LogIn }

class _LoginState extends State<Login>{
  LoginStatus _loginStatus = LoginStatus.notLogIn;
  String email, password;
  final _key = new GlobalKey<FormState>();

  bool _secureText = true;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() {
    final form = _key.currentState;
    if (form.validate()){
      form.save();
      login();
    }
  }

  login() async {
    Map bodyMap = {
      'user': {
        'email': email,
        'password': password,
    }};
    
    final response = await http
        .post(LOGIN_API,
        headers: {"Content-Type": "application/json"},
        body: json.encode(bodyMap));

    final data = jsonDecode(response.body);
    String status = data['status'];
    if (status=='OK'){
      // login successfully
      String token = data['token'];
      var user = data['user'];
      String username = user['username'];
      int id = user['id'];
      int state = 1;
      savePref(state, token, email, username, password, id);
      print(status);
      getPref(); // re-draw and re-direct to data page
    } else if (status=="error"){
      // user not activated
    }else {
      // wrong email or pass
    }
  }

  loginToast(String toast) {
    return Fluttertoast.showToast(
        msg: toast,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white
    );
  }

  savePref(int state, String token, String email, String username, String password, int id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt('state', state); // 1 - loggedIn ; null - not LoggedIn
      preferences.setString('token',token);
      preferences.setString('email',email);
      preferences.setString('username', username);
      preferences.setString('password', password);
      preferences.setInt('id', id);
      // preferences.commit();
    });
  }

  var state;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      state = preferences.getInt('state');
      _loginStatus = state == 1 ? LoginStatus.LogIn:LoginStatus.notLogIn;
    });
  }

  logOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt('state', null); // 1 - loggedIn ; 0 - not LoggedIn
      preferences.setString('token',null);
      preferences.setString('email', null);
      preferences.setString('username', null);
      preferences.setString('password', null);
      preferences.setInt('id', null);
      // preferences.commit();
      _loginStatus = LoginStatus.notLogIn;
    });
  }

  @override
  void initState(){

    super.initState();
    getPref();
  }

  Widget build(BuildContext context){
    switch(_loginStatus){
      case LoginStatus.notLogIn:
        return Scaffold(
          backgroundColor: Colors.grey,
          body: Center(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.all(15.0),
                children: <Widget>[
                  Center(
                      child: Container(
                          padding: const EdgeInsets.all(8.0),
                          color: Colors.grey.withAlpha(20),
                          // color: Colors.grey,
                          child: Form(
                              key: _key,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset("assets/logo.png"),
                                  SizedBox(height: 40,),
                                  SizedBox(
                                    height: 50,
                                    child: Text(
                                      'Login',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 30.0
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 25,
                                  ),

                                  // card for email textFormField
                                  Card(
                                    elevation: 6.0,
                                    child: TextFormField(
                                      validator: (e) {
                                        if (e.isEmpty) {
                                          return "Please Insert Email";
                                        }
                                        return null;
                                      },
                                      onSaved: (e)=> email = e,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w300,
                                      ),

                                      decoration: InputDecoration(
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.only(left: 30,right: 15),
                                          child: Icon(Icons.person, color: Colors.grey),
                                        ),
                                        contentPadding: EdgeInsets.all(18),
                                        labelText: "Email",
                                      ),
                                    ),
                                  ),

                                  // Card for password TextFormField
                                  Card(
                                    elevation: 6.0,
                                    child: TextFormField(
                                      validator: (e){
                                        if (e.isEmpty) {
                                          return "Password Can't be empty!";
                                        }
                                        return null;
                                      },
                                      obscureText: _secureText,
                                      onSaved: (e)=> password = e,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w300,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: "Password",
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.only(left: 20, right: 15),
                                          child: Icon(Icons.lock, color: Colors.grey),
                                        ),
                                        suffixIcon: IconButton(
                                          onPressed: showHide(),
                                          icon: Icon(_secureText
                                              ? Icons.visibility_off
                                              : Icons.visibility),
                                        ),
                                        contentPadding: EdgeInsets.all(18),
                                      ),

                                    ),

                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),

                                  Padding(
                                    padding: EdgeInsets.all(14.0),
                                  ),

                                  new Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 44.0,
                                        child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15.0)
                                          ),
                                          child: Text(
                                            "Login",
                                            style: TextStyle(fontSize: 18.0),
                                          ),
                                          textColor: Colors.white,
                                          color: Color(0xFFf7d426),
                                          onPressed: (){
                                            check();
                                          },
                                        ),
                                      ),

                                      SizedBox(
                                          height: 44.0,
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(15),
                                            ),
                                            child: Text(
                                              "Registration",
                                              style: TextStyle(fontSize: 18.0),
                                            ),
                                            textColor: Colors.white,
                                            color: Color(0xFFf7d426),
                                            onPressed: (){
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => Register()
                                                ),
                                              );
                                            },
                                          )

                                      )
                                    ],
                                  )
                                ],
                              )
                          )
                      )
                  )
                ],

              )
          ),

        );
        break;

      case LoginStatus.LogIn:
        return MainMenu(logOut);
        break;
    }
  }
}

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
  }

class _RegisterState extends State<Register> {
  String firstName, lastName, username, email, password, rePassword, token;

  final _formKey = new GlobalKey<FormState>();

  bool _secureText = true;

  showHide(){
    setState(() {
      _secureText =!_secureText;
    });
  }

  check() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      save();
    }
  }

  save() async {
    Map bodyMap = {
      'user': {
        'username': username,
        'firstname': firstName,
        'lastname': lastName,
        'email': email,
        'password': password,
        'repeat_password': rePassword,
      }
    };
    final response = await http
        .post(REG_API,
        headers: {"Content-Type": "application/json"},
        body: json.encode(bodyMap));

    final data = jsonDecode(response.body);
    String status = data["status"];
    if (status.isNotEmpty){
      // success
      var user = data["user"];
      var activationLink = data["activation"];
      print("reg sucess");
       getActivation(activationLink);
    } else {
      String error = data["error"];
      print(error);
      registerToast(error);
    }
  }

  getActivation(link) async {
    final response = await http.get(link);
    final data = jsonDecode(response.body);
    String status = data["status"];
    if (status.isNotEmpty){
      var user = data["user"];
      int id = user["id"];
      token = data["token"];
      savePref(1, token, email, username, password, id);
      setState(() {
        Navigator.pop(context);
      });
    }
  }

  savePref(int state, String token, String email, String username, String password, int id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt('state', state); // 1 - loggedIn ; null - not LoggedIn
      preferences.setString('token',token);
      preferences.setString('email',email);
      preferences.setString('username', username);
      preferences.setString('password', password);
      preferences.setInt('id', id);
      // preferences.commit();
    });
  }
  
  registerToast(String toast){
    return Fluttertoast.showToast(
      msg: toast,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIos: 3,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(15.0),
          children: <Widget>[
            Center(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.grey,
                child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset('assets/logo.png'),
                        SizedBox(height: 40,),
                        SizedBox(
                          height: 50,
                          child: Text(
                            "Registration",
                            style: TextStyle(color: Colors.white, fontSize: 30.0),
                          ),
                        ),
                        SizedBox(height: 25,),

                        //Card for username TextFormField
                        Card(
                          elevation: 6.0,
                          child: TextFormField(
                            validator: (e) {
                              if(e.isEmpty){
                                return "please insert your username.";
                              }
                              return null;
                            },
                            onSaved: (e)=> username = e,
                            style: TextStyle(
                              color:  Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(left: 20, right: 15),
                                child: Icon(Icons.person, color: Colors.grey),
                              ),
                              contentPadding: EdgeInsets.all(18),
                              labelText: "Username",
                            ),
                          ),
                        ),

                        //Card for first name TextFormField
                        Card(
                          elevation: 6.0,
                          child: TextFormField(
                            validator: (e) {
                              if(e.isEmpty){
                                return "please insert your first name.";
                              }
                              return null;
                            },
                            onSaved: (e)=> firstName = e,
                            style: TextStyle(
                              color:  Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(left: 20, right: 15),
                                child: Icon(Icons.label, color: Colors.grey),
                              ),
                              contentPadding: EdgeInsets.all(18),
                              labelText: "First name",
                            ),
                          ),
                        ),

                        //Card for last name TextFormField
                        Card(
                          elevation: 6.0,
                          child: TextFormField(
                            validator: (e) {
                              if(e.isEmpty){
                                return "please insert your first name.";
                              }
                              return null;
                            },
                            onSaved: (e)=> lastName = e,
                            style: TextStyle(
                              color:  Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(left: 20, right: 15),
                                child: Icon(Icons.label, color: Colors.grey),
                              ),
                              contentPadding: EdgeInsets.all(18),
                              labelText: "Last name",
                            ),
                          ),
                        ),

                        // card for Email TextFormField
                        Card(
                          elevation: 6.0,
                          child: TextFormField(
                            validator: (e) {
                              if (e.isEmpty) {
                                return "please enter your email.";
                              }
                              return null;
                            },
                            onSaved: (e)=>email = e,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                            decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: EdgeInsets.only(left: 20, right: 15),
                                  child: Icon(Icons.email, color:Colors.grey),
                                ),
                                contentPadding: EdgeInsets.all(18),
                                labelText: "Email"
                            ),
                          ),
                        ),

                        // Card for password TextFormFeld
                        Card(
                          elevation: 6.0,
                          child: TextFormField(
                            obscureText: _secureText,
                            onSaved: (e)=> password = e,
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w300,
                            ),
                            decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: showHide,
                                  icon: Icon(_secureText
                                      ? Icons.visibility_off
                                      :Icons.visibility),
                                ),
                                prefixIcon: Padding(
                                  padding: EdgeInsets.only(left: 20, right: 15),
                                  child: Icon(Icons.lock, color: Colors.grey),
                                ),
                                contentPadding: EdgeInsets.all(18),
                                labelText: "Password"
                            ),
                          ),
                        ),

                        // Card for re-password TextFormFeld
                        Card(
                          elevation: 6.0,
                          child: TextFormField(
                            obscureText: _secureText,
                            validator: (e){
                              if(e.isEmpty){
                                return "please re-enter password";
                              }
                              return null;
                            },
                            onSaved: (e)=> rePassword = e,
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w300,
                            ),
                            decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: showHide,
                                  icon: Icon(_secureText
                                      ? Icons.visibility_off
                                      :Icons.visibility),
                                ),
                                prefixIcon: Padding(
                                  padding: EdgeInsets.only(left: 20, right: 15),
                                  child: Icon(Icons.lock, color: Colors.grey),
                                ),
                                contentPadding: EdgeInsets.all(18),
                                labelText: "Re-enter Password"
                            ),
                          ),
                        ),

                        Padding(padding: EdgeInsets.all(12.0),),

                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SizedBox(
                              height: 44.0,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Text(
                                  "Register Now",
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                textColor: Colors.white,
                                color: Color(0xFFf7d426),
                                onPressed: (){
                                  check();
                                },
                              ),
                            ),
                            SizedBox(
                              height: 44.0,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Text(
                                  "Go to Login",
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                textColor: Colors.white,
                                color: Color(0xFFf7d426),
                                onPressed: (){
                                  /*
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => Login()
                                      ));

                                   */
                                  Navigator.pop(context);

                                },
                              ),
                            )
                          ],
                        )

                      ],
                    )
                ),

              )
            )
          ],
        )
      )
    );
  }
  

}

class MainMenu extends StatefulWidget {
  final VoidCallback logOut;

  MainMenu(this.logOut);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  logOut(){
    setState(() {
      widget.logOut();
    });
  }

  int currentIndex = 0;
  String selectedIndex = 'TAB: 0';
  String email = "", username = "";
  TabController tabController;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      email = preferences.getString("email");
      username = preferences.get("username");
    });
    // print("username"+username);

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: (){
              logOut();
            },
            icon: Icon(Icons.lock_open),
          )
        ],
      ),
      body: Center(
        child: Text(
          "page for data view",
          style: TextStyle(fontSize: 30.0, color: Colors.blue),
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        backgroundColor: Colors.grey,
        iconSize:30.0,
        currentIndex: currentIndex,
        onItemSelected: (index){
          setState(() {
            currentIndex = index;
          });
          selectedIndex = 'TAB: $currentIndex';
          // print(seletedIndex);
          redirectTo(selectedIndex);
        },
        items: [
          BottomNavyBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
            activeColor: Color(0xFFf7d426)
          ),
          BottomNavyBarItem(
              icon: Icon(Icons.history),
              title: Text('History'),
              activeColor: Color(0xFFf7d426)
          ),
        ],
      ),
    );
  }

  // action on Bottom bar Items
  void redirectTo(selectedIndex){
    switch (selectedIndex) {
      case "TAB:0":
        {
          print("[TAB:0]" + selectedIndex);
        }
        break;
      case "TAB:1":
        {
          print("[TAB:1]" + selectedIndex);
        }
        break;
    }
  }


}