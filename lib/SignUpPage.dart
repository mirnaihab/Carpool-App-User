import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'LoginPage.dart';
import 'Location.dart';
import 'firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}
class _SignUpPageState extends State<SignUpPage>{

  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  bool isSigningUp = false;

  String errorMessage = '';
  late FirebaseFirestore firestore;
  late CollectionReference users;

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
    users = firestore.collection('Users');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade300,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: screenHeight * 0.02),
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text(
                'Login',
                style: TextStyle(fontSize: screenHeight * 0.032),
              ),
              style: TextButton.styleFrom(
                primary: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child:
        Container(
          color: Colors.grey.shade200,
          padding: EdgeInsets.only(left: screenHeight * 0.03, right: screenHeight * 0.03, top:screenHeight*0.15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  "Sign Up",
                  style: GoogleFonts.pangolin(
                    textStyle: TextStyle(fontSize: screenHeight * 0.09, color: Colors.grey.shade800, height: screenHeight * 0.0001),
                  ),
                ),
              ),
              Center(
                child: Text("Create an account:",
                  style: GoogleFonts.pangolin(
                    textStyle: TextStyle(fontSize: screenHeight * 0.035, color: Colors.grey.shade800, height: screenHeight * 0.004),
                  ),),
              ),
              SizedBox(height: screenHeight * 0.01),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300, // Background color for the TextField
                  borderRadius: BorderRadius.circular(screenHeight * 0.015), // Adjust the border radius as needed
                ),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'email',
                    hintText: 'email@eng.asu.edu.eg',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(screenHeight * 0.03)),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300, // Background color for the TextField
                  borderRadius: BorderRadius.circular(screenHeight * 0.015), // Adjust the border radius as needed
                ),
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(screenHeight * 0.03)),
                  ),
                  // obscureText: true,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300, // Background color for the TextField
                  borderRadius: BorderRadius.circular(screenHeight * 0.015), // Adjust the border radius as needed
                ),
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(screenHeight * 0.03)),
                  ),
                  obscureText: true,
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300, // Background color for the TextField
                  borderRadius: BorderRadius.circular(screenHeight * 0.015), // Adjust the border radius as needed
                ),
                child: TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(screenHeight * 0.03)),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              if (errorMessage.isNotEmpty) // Check if there's an error message
                Text(
                  errorMessage,
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: screenHeight*0.027// Customize the error text color
                  ),
                ),
              SizedBox(height: screenHeight * 0.02),
              Padding(
                padding: EdgeInsets.only(bottom: screenHeight*0.1),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenHeight * 0.015),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade300, Colors.deepPurple.shade200],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      _signUp();
                    },
                    child: Text(
                      'Register',
                      style: GoogleFonts.pangolin(
                        textStyle: TextStyle(fontSize: screenHeight * 0.035, color: Colors.grey.shade900),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenHeight * 0.015),
                      ),
                      minimumSize: Size(double.infinity, screenHeight * 0.065),
                      elevation: 0, // Optional: Set elevation to 0 for a flat design
                      backgroundColor: Colors.transparent, // Set the button's background to transparent
                      foregroundColor: Colors.transparent,  // Set the button's splash color to transparent
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )

    );


  }
  void _signUp() async {

    setState(() {
      isSigningUp = true;
      errorMessage = '';
    });

    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    // int phone = int.parse(_phoneController.text);

    RegExp emailPattern = RegExp(r'^[0-9]{2}p[0-9]{4}@eng\.asu\.edu\.eg$');

    if (username.isEmpty || email.isEmpty || password.isEmpty ) {
      setState(() {
        isSigningUp = false;
        // Set an error message for empty fields
        errorMessage = 'Some fields are missing';
      });
      return; // Exit the method if any field is empty
    }

    String phoneText = _phoneController.text;
    if (phoneText.isEmpty || !RegExp(r'^[0-9]{11}$').hasMatch(phoneText)) {
      setState(() {
        isSigningUp = false;
        errorMessage = 'Please enter a valid 11-digit phone number';
      });
      return;
    }

// If the input is valid, parse it as an int
    int phone = int.parse(phoneText);


    if (!emailPattern.hasMatch(email)) {
      setState(() {
        isSigningUp = false;
        // Set an error message for invalid email format
        errorMessage = 'Please enter a valid XXpXXXX@eng.asu.edu.eg email format';
      });
      return; // Exit the method if the email format is invalid
    }
    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    setState(() {
      isSigningUp = false;
    });
    if (user != null) {
      await users.doc(user.uid).set({
        'email': email,
        'username': username,
        'password': sha256.convert(utf8.encode(password)).toString(),
        'phone': phone,
      });
      // Fluttertoast.showToast(msg: "User is successfully created");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Location()),
      );
    } else {
      errorMessage='email already in use';
      print("errrrrrorrrrrr");
      // Fluttertoast.showToast(msg: "Some error happend");
    }
  }
}
