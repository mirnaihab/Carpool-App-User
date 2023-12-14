import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Location.dart';
import 'firebase_auth_services.dart';
import 'LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'OrderHistory.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, String> profileDetails = {
    'Name': 'Mirna Ihab',
    'Phone': '03107085816',
    'Email': '16p6793@eng.asu.edu.eg',
  };

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
              ), SizedBox(height: screenHeight * 0.06),
              for (var entry in profileDetails.entries)
                itemProfile(entry.key, entry.value, _getIcon(entry.key)),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String key) {
    switch (key) {
      case 'Name':
        return CupertinoIcons.person;
      case 'Phone':
        return CupertinoIcons.phone;
      case 'Email':
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
                    setState(() {
                      profileDetails[title] =
                          textEditingController
                              .text; // Update the map entry with edited value
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('Save', style: TextStyle(fontSize: 20, color: Colors.grey.shade900)),
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