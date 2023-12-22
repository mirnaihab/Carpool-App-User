import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Location.dart';
import 'firebase_auth_services.dart';
import 'LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'OrderHistory.dart';
import 'DatabaseHelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserProfile {
  final String? uid;
   String email;
   String username;
   int phone;

  UserProfile({
    required this.uid,
    required this.email,
    required this.username,
    required this.phone,
  });

  void setEmail(String newEmail) {
    email = newEmail;
  }

  void setUsername(String newUsername) {
    username = newUsername;
  }

  void setPhone(int newPhone) {
    phone = newPhone;
  }

  // Convert a Map<String, dynamic> to a UserProfile object
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'],
      email: map['email'],
      username: map['username'],
      phone: map['phone'],
    );
  }

  // Convert a UserProfile object to a Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'phone': phone,
    };
  }
}


class ProfilePage extends StatefulWidget {
  final String userId;


  ProfilePage({required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  late UserProfile? userProfile = UserProfile(uid: "", email: "", username: "", phone: 0);
  late DatabaseHelper dbHelper = DatabaseHelper();

  // Map<String, String> profileDetails = {
  //   'Name': 'Mirna Ihab',
  //   'Phone': '03107085816',
  //   'Email': '16p6793@eng.asu.edu.eg',
  // };

  @override
  void initState(){
    super.initState();
    initializeUid();

  }

  void initializeUid() async{
    if (widget.userId != null) {
      dbHelper = DatabaseHelper();
      await dbHelper.updateSQLiteFromFirestore(widget.userId);
      fetchUserProfile();
    }
  }

  void fetchUserProfile() async {
    // Fetch user profile data from SQLite based on userId
    if (widget.userId != null) {
      userProfile = await dbHelper.getUserProfile(widget.userId!);
      setState(() {});

    }
  }
  void _updateUserDetails(String field, String newValue) async {
    try {
      if (widget.userId != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.userId)
            .update({field: newValue});

        setState(() {
          // Update the local userProfile object when the data is updated in Firestore
          if (field == 'email') {
            userProfile?.setEmail(newValue);
          } else if (field == 'username') {
            userProfile?.setUsername(newValue);
          } else if (field == 'phone') {
            userProfile?.setPhone(int.parse(newValue));
          }
        });
      }
    } catch (e) {
      print("Error updating data: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Location()),
            );
          },
        ),
        centerTitle: true,
        title: Text(
          "Profile",
          style: GoogleFonts.pangolin(
            textStyle: TextStyle(
                fontSize: screenHeight * 0.04, color: Colors.grey.shade900),
          ),
        ),
        backgroundColor: Colors.blueGrey.shade300,
        actions: [

          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>
                    OrderHistory(), // Replace with your OrderHistory page
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>
                    LoginPage(), // Replace with your OrderHistory page
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade200,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.07),
              CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage('assets/profile.png'),
              ),
              SizedBox(height: screenHeight * 0.06),
              itemProfile('username', userProfile?.username ?? '', CupertinoIcons.person),
              itemProfile('phone', userProfile?.phone.toString() ?? '', CupertinoIcons.phone),
              itemProfile('email', userProfile?.email ?? '', CupertinoIcons.mail),
            ],

          ),
        ),
      ),
    );
  }

  IconData _getIcon(String key) {
    switch (key) {
      case 'username':
        return CupertinoIcons.person;
      case 'phone':
        return CupertinoIcons.phone;
      case 'email':
        return CupertinoIcons.mail;
      default:
        return Icons.error;
    }
  }

  itemProfile(String title, String subtitle, IconData iconData) {
    TextEditingController textEditingController = TextEditingController(
      text: subtitle,
    );

    return GestureDetector(
      onTap: title == 'Email' ? null : () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.grey.shade300,
              title: Text('Edit $title'),
              content: TextField(
                controller: textEditingController,
                decoration: InputDecoration(hintText: 'Enter new $title'),
              ),
              actions: [
                TextButton(
                  onPressed: () {

                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel', style: TextStyle(fontSize: 20, color: Colors.grey.shade900)),
                ),
                TextButton(
                  onPressed: () {
                    _updateUserDetails(
                      title,
                      textEditingController.text,
                    );
                    setState(() {
                      if (title == 'email') {
                        userProfile?.setEmail(textEditingController.text);
                      } else if (title == 'username') {
                        userProfile?.setUsername(textEditingController.text);
                      } else if (title == 'Phone') {
                        userProfile?.setPhone(int.parse(textEditingController.text));
                      }
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 20, color: Colors.grey.shade900),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 5),
                color: Colors.purple.shade300,
                spreadRadius: 2,
                blurRadius: 10,
              ),
            ],
          ),
          child: ListTile(
            title: Text(title),
            subtitle: Text(subtitle),
            leading: Icon(iconData),
            trailing: Icon(Icons.arrow_forward, color: Colors.grey.shade500),
            tileColor: Colors.white,
          ),
        ),
      ),
    );
  }
}

