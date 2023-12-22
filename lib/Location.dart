import 'package:flutter/material.dart';
import 'package:project/Profile.dart';
import 'Cart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'OrderHistory.dart';
import 'LoginPage.dart';
import 'firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Profile.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Locations {
  final String name;
  final String imagePath;
  final double price;
  final String meetingpoint;
  final String username;
  final String id;

  Locations(this.name, this.imagePath, this.price, this.meetingpoint,
      this.username, this.id);
}

class Location extends StatefulWidget {
  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  // List<Locations> locations = [];
  User? user = FirebaseAuth.instance.currentUser;
  late Stream<List<Locations>> locationsStream = Stream
      .empty(); // Locations('El Abasseya', 'assets/abasseya.jpg', 30.0, "Zafaran Palace"),
  // Locations('Abdu-Basha', 'assets/abdubasha.jpg', 20.0, "Abdu-Basha Square"),
  // Locations('Heliopolis', 'assets/heliopolis.jpg', 35.0, "The Basilique"),
  // Locations('Nasr City', 'assets/nasrcity.jpg', 50.0, "El Nasr Road"),
  // Locations('El Tahrir', 'assets/tahrir.jpg', 80.0, "El Tahrir Square"),
  // Locations('El Rehab', 'assets/elrehab.jpg', 120.0, "Gate 20"),
  // Locations('Garden City', 'assets/gardencity.jpg', 100.0, "The Ethnographic Museum"),
  // Locations('Madinaty', 'assets/madinaty.jpg', 150.0, "Open Air Mall"),
  // Locations('El zamalek', 'assets/elzamalek.jpg', 90.0, "Aisha Fahmy Palace"),
  // Locations('El Haram', 'assets/haram.jpg', 100.0, "El Haram Street"),
  // Locations('El Zatoon', 'assets/alkoba.jpg', 40.0, "Qoba Palace"),

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OrderHistory(), // Replace with your OrderHistory page
                ),
              );
            },
          ),
          centerTitle: true,
          title: Text(
            "Choose your Location",
            style: GoogleFonts.pangolin(
              textStyle: TextStyle(
                  fontSize: screenHeight * 0.035, color: Colors.grey.shade900),
            ),
          ),
          backgroundColor: Colors.blueGrey.shade300,
          actions: [
            IconButton(
              icon: Icon(Icons.account_circle), // Profile icon
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfilePage(userId: user!.uid), // Replace with your OrderHistory page
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
                  MaterialPageRoute(
                    builder: (context) =>
                        LoginPage(), // Replace with your OrderHistory page
                  ),
                );
              },
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('Drivers').snapshots(),
            builder: (context, driverSnapshot) {
              if (!driverSnapshot.hasData) {
                return CircularProgressIndicator(); // Loading indicator
              }

              final drivers = driverSnapshot.data!.docs;

              return ListView.builder(
                  itemCount: drivers.length,
                  itemBuilder: (context, index) {
                    final driverId = drivers[index].id;
                    final driverData =
                        drivers[index].data() as Map<String, dynamic>;

                    String driverName = driverData['username'] ?? '';
                    List<String> parts = driverData['email'].split('@');
                    String id = parts[0];

                    return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('Drivers')
                            .doc(driverId)
                            .collection('Routes')
                            .snapshots(),
                        builder: (context, routeSnapshot) {
                          if (!routeSnapshot.hasData) {
                            return CircularProgressIndicator(); // Loading indicator
                          }

                          final routes = routeSnapshot.data!.docs;

                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Text('Driver ID: $driverId'),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: routes.length,
                                  itemBuilder: (context, routeIndex) {
                                    final routeData = routes[routeIndex].data()
                                        as Map<String, dynamic>;

                                    String imagePath = routeData['imagePath'];

                                    Widget imageWidget;
                                    if (imagePath.startsWith('asset')) {
                                      imageWidget = Image.asset(
                                        imagePath,
                                        width: screenWidth * 0.32,
                                        height: screenHeight * 0.17,
                                        fit: BoxFit.cover,
                                      );
                                    } else {
                                      imageWidget = Image.network(
                                        imagePath,
                                        width: screenWidth * 0.32,
                                        height: screenHeight * 0.17,
                                        fit: BoxFit.cover,
                                      );
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2.5),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          color: Colors.grey
                                              .shade300, // Set darker background color here
                                        ),
                                        child: ListTile(
                                          title: Row(
                                            children: [
                                              imageWidget,
                                              SizedBox(
                                                  width: screenWidth * 0.1),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    routeData['name'],
                                                    // locations[index].name,
                                                    style: GoogleFonts.pangolin(
                                                      textStyle: TextStyle(
                                                        fontSize:
                                                            screenHeight * 0.05,
                                                        color: Colors
                                                            .grey.shade900,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      height:
                                                          screenHeight * 0.001),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.location_pin),
                                                      Text(
                                                        routeData[
                                                            'meetingpoint'],
                                                        // locations[index].meetingpoint,
                                                        style: GoogleFonts
                                                            .pangolin(
                                                          textStyle: TextStyle(
                                                            fontSize:
                                                                screenHeight *
                                                                    0.023,
                                                            color: Colors
                                                                .grey.shade900,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        screenHeight * 0.001,
                                                  ),
                                                  Text(
                                                    "Price: ${routeData['price'].toString()}",
                                                    // "Price: ${locations[index].price.toString()}",
                                                    style: GoogleFonts.pangolin(
                                                      textStyle: TextStyle(
                                                        fontSize:
                                                            screenHeight * 0.03,
                                                        color: Colors
                                                            .grey.shade900,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        screenHeight * 0.001,
                                                  ),
                                                  Text(
                                                    "Driver: ${driverData['username']}",
                                                    style: GoogleFonts.pangolin(
                                                      textStyle: TextStyle(
                                                        fontSize:
                                                            screenHeight * 0.03,
                                                        color: Colors
                                                            .grey.shade900,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        screenHeight * 0.001,
                                                  ),
                                                  Text(
                                                    "Driver's id: ${id}",
                                                    style: GoogleFonts.pangolin(
                                                      textStyle: TextStyle(
                                                        fontSize:
                                                            screenHeight * 0.03,
                                                        color: Colors
                                                            .grey.shade900,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Cart(
                                                  locations: Locations(
                                                    routeData['name'],
                                                    routeData['imagePath'],
                                                    routeData['price']
                                                        .toDouble(),
                                                    routeData['meetingpoint'],
                                                    driverData['username'],
                                                    id,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                )
                              ]);
                        });
                  });
            }));
  }
}
