/*
 * File: /loginRegShared.dart
 * Project: Thingy-mobile-client-yellow
 * File Created: Thu, 12th December 2019 12:27:48 am
 * Author: Yi Zhang (yi.zhang@unifr.ch)
 * -----
 * Copyright 2019 - 2019 AES-Unifr, AES2019-Yellow
 */
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:geolocator/geolocator.dart';

const LOGIN_API = "http://127.0.0.1:3000/login/";
const REG_API = "http://127.0.0.1:3000/register/";
const DEVICE_API = "http://127.0.0.1:3000/devices/";
const HOST = "http://127.0.0.1:3000";
const AERIS_API_SECRET = "iSgRXRaZBQJGtlveYR1mVuD6pTkePdnqK19VUf25";
const AERIS_API_KEY = "lb0lr2m16uYd0oENeFeZy";
const OPEN_WEATHER_API_KEY = "8f343836a14787d4573a0daabf48adc0";
const AERIS_API_PREF = "http://api.aerisapi.com/airquality/";
//HOST + long,lat+?client_id=$AERIS_API_KEY&clinet_secret=$AERIS_API_SECRET
const OPEN_WEATHER_API_PREF = "http://api.openweathermap.org/data/2.5/weather";
// http://api.openweathermap.org/data/2.5/weather?lat=${location.coords.latitude}&lon=${location.coords.longitude}&units=metric&APPID=${OPENWEATHER_API_KEY}`
const DEFAULT_LAT = "46.7940";
const DEFAULT_LONG = "7.1577";
class Login extends StatefulWidget {
  @override
  _LoginState createState()=> _LoginState();
}

enum LoginStatus { notLogIn, LogIn }
enum SuffocationLevel {suffocationHigh, suffocationMedium, suffocationLow}
extension SuffocationLevelExtension on SuffocationLevel{
  String get name{
    switch (this) {
      case SuffocationLevel.suffocationHigh:
        return "High";
      case SuffocationLevel.suffocationMedium:
        return "Medium";
      case SuffocationLevel.suffocationLow:
        return "Low";
    }
  }
}

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
  SharedPreferences sharedPreferences;
  int currentIndex = 0;
  String selectedIndex = 'TAB: 0';
  String email = "", username = "";
  TabController tabController;
  Geolocator geolocator = Geolocator();
  GeolocationStatus _geolocationStatus;
  Position currentPosition;
  String device;
  String token;
  String inTemp;
  String inHum;
  String inCO2;
  double outTemp;
  int outHum;



  getPref() {
    SharedPreferences.getInstance().then((SharedPreferences sp){
      sharedPreferences = sp;
      email = sp.getString("email");
      username = sp.get("username");
      token = sp.get("token");
    });
    setState(() {

    });
    // print("username"+username);

  }

  Future<String> getToken() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    return token;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
  }

  checkGeo() async {
    _geolocationStatus  = await Geolocator().checkGeolocationPermissionStatus();
    print(_geolocationStatus.toString());
  }

  getDevice() async {
    final auth = "Bearer "+ await getToken();
    final response = await http.get(DEVICE_API,
        headers: {"Content-Type": "application/json",
        "Authorization": auth},
        );
    final data = jsonDecode(response.body);
    device = data["devices"][0];
  }

  Future<String> _getInTemperature() async{
    final urlArray = [HOST, device, "temperature"];
    final url = urlArray.join("/");
    final response = await http.get(url,
      headers: {"Content-Type": "application/json",
        "Authorization":"Bearer "+token},);
    //print(token);
    final data = jsonDecode(response.body); // array
    List temperatureList = data.map((e)=>double.parse(e['temperature'])).toList();
    //print(temperatureList.toString());
    double sum = temperatureList.reduce((a,b)=>a+b);
    double mean = sum/temperatureList.length;
    return mean.toStringAsFixed(1);
}
  Future<String> _getInHumidity() async{
    final urlArray = [HOST, device, "humidity"];
    final url = urlArray.join("/");
    final response = await http.get(url,
      headers: {"Content-Type": "application/json",
        "Authorization":"Bearer "+token},);
    final data = jsonDecode(response.body); // array
    List humidityList = data.map((e)=>double.parse(e['humidity'])).toList();
    double sum = humidityList.reduce((a,b)=>a+b);
    double mean = sum/humidityList.length;
    return mean.toStringAsFixed(1);
  }

  Future<String> _getInCO2() async{
    final urlArray = [HOST, device, "airquality"];
    final url = urlArray.join("/");
    final response = await http.get(url,
      headers: {"Content-Type": "application/json",
        "Authorization":"Bearer "+token},);
    final data = jsonDecode(response.body); // array
    List cO2List = data.map((e)=>double.parse(e['CO2'])).toList();
    double sum = cO2List.reduce((a,b)=>a+b);
    double mean = sum/cO2List.length;
    return mean.toStringAsFixed(1);
  }

Future<Map> _getOutWeather() async{
    var long, lat;
    if (currentPosition==null){
      long = DEFAULT_LONG;
      lat = DEFAULT_LAT;
    }else {
      long = currentPosition.longitude.toString();
      lat = currentPosition.latitude.toString();
    }
    final url = OPEN_WEATHER_API_PREF
        + "?lat="+lat
        +"&lon="+long
        +"&units=metric&APPID="+OPEN_WEATHER_API_KEY;
    final response = await http.get(url,
      headers: {"Content-Type": "application/json"});
    final data = jsonDecode(response.body);
    var outTemperature = data['main']['temp'];
    var outHumidity = data['main']['humidity'];
    var res =  {
      "temperature":outTemperature,
      "humidity": outHumidity,
    };
    return res;
}

Future<SuffocationLevel> _getSuffocationLevel() async {

    var tempDiff = (double.parse(inTemp)-outTemp).abs();
    var humDiff = (double.parse(inHum)-outHum).abs();
    if (tempDiff>25 || humDiff > 80 || double.parse(inCO2)>2000 ) {
      return SuffocationLevel.suffocationHigh;
    } else if (tempDiff > 10 || humDiff > 40 || double.parse(inCO2)>1000){
      return SuffocationLevel.suffocationMedium;
    } else {
      return SuffocationLevel.suffocationLow;
    }
}

  Future<Position> _getLocation() async {
    try {
      currentPosition = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentPosition = null;
    }
    print(currentPosition.toString());
    return currentPosition;
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    checkGeo();
    _getLocation();
    getDevice();


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
      /*body: *Center(
        child: Text(
          "Location: ",
          style: TextStyle(fontSize: 30.0, color: Colors.blue),
        ),
      ),*/
      body: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            child: Container(
              child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Text("In Temp.",
                      style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize:21.0),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: EdgeInsets.only(top: 25.0, bottom: 10.0),
                    child: FutureBuilder<String>(
                      future: _getInTemperature(),
                        builder: (context,snapshot){
                          if (snapshot.hasData){
                            inTemp = snapshot.data;
                            return Text(snapshot.data + " °C",
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize:42.0),
                              textAlign: TextAlign.center,
                            );} else if (snapshot.hasError) {
                            return Text("");
                            // do something.
                          }
                          return CircularProgressIndicator();
                        }
                    )

                  ),
                ),
              ])),
            color: Colors.teal[100],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Container(
                child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Text("Out Temp.",
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize:21.0),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                            margin: EdgeInsets.only(top: 25.0, bottom: 10.0),
                            child: FutureBuilder<Map>(
                                future: _getOutWeather(),
                                builder: (context,snapshot){
                                  if (snapshot.hasData){
                                    outTemp = snapshot.data['temperature'];
                                    return Text(snapshot.data['temperature'].toStringAsFixed(1) + " °C",
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold,
                                          fontSize:42.0),
                                      textAlign: TextAlign.center,
                                    );} else if (snapshot.hasError) {
                                    return Text("error");

                                  }
                                  return CircularProgressIndicator();
                                }
                            )
                        ),
                      ),
                    ])),
            color: Colors.teal[200],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Container(
                child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Text("In Humidity",
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize:21.0),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                            margin: EdgeInsets.only(top: 25.0, bottom: 10.0),
                            child: FutureBuilder<String>(
                                future: _getInHumidity(),
                                builder: (context,snapshot){
                                  if (snapshot.hasData){
                                    inHum = snapshot.data;
                                    return Text(snapshot.data + " %",
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold,
                                          fontSize:42.0),
                                      textAlign: TextAlign.center,
                                    );} else if (snapshot.hasError) {
                                    return Text("");
                                    // do something.
                                  }
                                  return CircularProgressIndicator();
                                }
                            )

                        ),
                      ),
                    ])),
            color: Colors.teal[300],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Container(
                child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Text("Out Humidity",
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize:21.0),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                            margin: EdgeInsets.only(top: 25.0, bottom: 10.0),
                            child: FutureBuilder<Map>(
                                future: _getOutWeather(),
                                builder: (context,snapshot){
                                  if (snapshot.hasData){
                                    outHum = snapshot.data['humidity'];
                                    return Text(snapshot.data['humidity'].toString() + " %",
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold,
                                          fontSize:42.0),
                                      textAlign: TextAlign.center,
                                    );} else if (snapshot.hasError) {
                                    return Text("error");

                                  }
                                  return CircularProgressIndicator();
                                }
                            )
                        ),
                      ),
                    ])),
            color: Colors.teal[400],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Container(
                child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Text("CO2 ",
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize:21.0),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                            margin: EdgeInsets.only(top: 25.0, bottom: 10.0),
                            child: FutureBuilder<String>(
                                future: _getInCO2(),
                                builder: (context,snapshot){
                                  if (snapshot.hasData){
                                    inCO2 = snapshot.data;
                                    return Text(snapshot.data + " ppm.",
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold,
                                          fontSize:35.0),
                                      textAlign: TextAlign.right,
                                    );} else if (snapshot.hasError) {
                                    return Text("");
                                    // do something.
                                  }
                                  return CircularProgressIndicator();
                                }
                            )

                        ),
                      ),
                    ])),
            color: Colors.teal[500],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Container(
                child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Text("Risk of Suffocation:",
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize:21.0),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                            margin: EdgeInsets.only(top: 25.0, bottom: 10.0),
                            child: FutureBuilder<SuffocationLevel>(
                                future: _getSuffocationLevel(),
                                builder: (context,snapshot){
                                  if (snapshot.hasData){
                                    return Text(snapshot.data.name,
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold,
                                          fontSize:35.0),
                                      textAlign: TextAlign.right,
                                    );} else if (snapshot.hasError) {

                                    return Text("");
                                    // do something.
                                  }
                                  return CircularProgressIndicator();
                                },
                            )

                        ),
                      ),
                    ])),
            color: Colors.teal[600],
          ),
        ],
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
      case "TAB: 0":
        {
          setState(() {

          });
          print("[TAB: 0]" + selectedIndex);
        }
        break;
      case "TAB: 1":
        {
          print("[TAB: 1]" + selectedIndex);
        }
        break;
    }
  }


}