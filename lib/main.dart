import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options:FirebaseOptions(apiKey: 'AIzaSyDMDI3lql_1SQGaMWALNM6_YN6ZgNrEeZY', appId: '1:749073684778:android:111d20a3edfe3fe6362653', messagingSenderId: '749073684778', projectId: 'carpool-f804d'));
  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  runApp( MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      routes: {
        '/login': (context) => LoginPage(),
      },
    );
  }
}


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _navigateToLoginPage();
  }

  Future<void> _navigateToLoginPage() async {
    await Future.delayed(Duration(seconds: 6));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
  // bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    double screenheight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade400, Colors.deepPurple.shade200],
          ),
        ),

          child: Padding(
            padding: EdgeInsets.all(screenheight * 0.1025),
            child: Column(
              children: [
                Text(
                  'Welcome To',
                  style: GoogleFonts.pangolin(
                    textStyle: TextStyle(fontSize: screenheight * 0.06, color: Colors.white),
                  )
                ),
                SizedBox(height: screenheight * 0.01),
                Text("ASU CarPool",
                  style:
                    TextStyle(fontSize:screenheight * 0.065, color: Colors.white, fontWeight: FontWeight.bold),),
                SizedBox(height: screenheight * 0.1),
                Lottie.network("https://lottie.host/e1a19c07-86ff-4bd6-8820-793dd7875895/uo8W0o7UdM.json"),
                // Image.asset("assets/Group-1184@2x.png",
                //   height: modalHeight * 0.26,
                // ),
                SizedBox(height: screenheight * 0.13),
                Text("Get Started...",
                  style: GoogleFonts.pangolin(
                    textStyle: TextStyle(fontSize: screenheight * 0.06, color: Colors.white),
                ),),
                SizedBox(height: screenheight * 0.04),

              ],

            ),
          ),
        ),
      );

  }
}