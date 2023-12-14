import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'SignUpPage.dart';
import 'Payment.dart';
import 'Location.dart';
import 'firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage>{


  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool isSigningUp = false;

  String errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenheight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade300,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: screenheight * 0.02),
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: Text(
                'Sign Up',
                style: TextStyle(fontSize: screenheight * 0.032),
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
        padding: EdgeInsets.only(left: screenheight * 0.03, right: screenheight * 0.03, top:screenheight*0.2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                "Login",
                style: GoogleFonts.pangolin(
                  textStyle: TextStyle(fontSize: screenheight * 0.09, color: Colors.grey.shade800, height: screenheight * 0.0001),
                ),
              ),
            ),
            Center(
              child: Text("Log into your account:",
                style: GoogleFonts.pangolin(
                  textStyle: TextStyle(fontSize: screenheight * 0.035, color: Colors.grey.shade800, height: screenheight * 0.005),
                ),
                ),
            ),

            SizedBox(height: screenheight * 0.01),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300, // Background color for the TextField
                borderRadius: BorderRadius.circular(screenheight * 0.015), // Adjust the border radius as needed
              ),

              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'email',
                  hintText: 'email@eng.asu.edu.eg',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(screenheight * 0.03)),
                ),
              ),
            ),
            SizedBox(height: screenheight * 0.03),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300, // Background color for the TextField
                borderRadius: BorderRadius.circular(screenheight * 0.015), // Adjust the border radius as needed
              ),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(screenheight * 0.03)),
                ),
                obscureText: true,
              ),
            ),
            SizedBox(height: screenheight * 0.15),
            if (errorMessage.isNotEmpty) // Check if there's an error message
              Text(
                errorMessage,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: screenheight*0.027// Customize the error text color
                ),
              ),
            SizedBox(height: screenheight * 0.03),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenheight * 0.015),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade300, Colors.deepPurple.shade200],
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  _signIn();
                },
                child: Text(
                  'Sign in',
                  style: GoogleFonts.pangolin(
                    textStyle: TextStyle(fontSize: screenheight * 0.035, color: Colors.grey.shade900),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenheight * 0.015),
                  ),
                  minimumSize: Size(double.infinity, screenheight * 0.065),
                  elevation: 0, // Optional: Set elevation to 0 for a flat design
                  backgroundColor: Colors.transparent, // Set the button's background to transparent
                  foregroundColor: Colors.transparent, // Set the button's splash color to transparent
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
  void _signIn() async {

    setState(() {
      isSigningUp = true;
      errorMessage = ''; // Clear any previous error message
    });
    setState(() {
      isSigningUp = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        isSigningUp = false;
        // Set an error message for empty fields
        errorMessage = 'Some fields are missing';
      });
      return; // Exit the method if any field is empty
    }

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    setState(() {
      isSigningUp = false;
    });
    if (user != null) {
      print('user logged in');
      // Fluttertoast.showToast(msg: "User is successfully created");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Location()),
      );
    } else {
      setState(() {
        errorMessage = 'Invalid email or password. Please try again.'; // Set error message
      });
      print("errrrrrorrrrrr");
      // Fluttertoast.showToast(msg: "Some error happend");
    }
  }
}
