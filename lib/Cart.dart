import 'package:flutter/material.dart';
import 'Location.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Payment.dart';
import 'OrderHistory.dart';
import 'LoginPage.dart';
import 'firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Cart extends StatefulWidget {
  final Locations locations;

  Cart({required this.locations});

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  bool isLoading = false;
  User? user = FirebaseAuth.instance.currentUser;  // Add a FirebaseAuth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // _user = FirebaseAuth.instance.currentUser;
  // Function to create a request in Firestore
  Future<void> createRequest() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Fetch the currently logged-in user
      User? user = _auth.currentUser;

      // Get the user ID
      String? userID = user?.uid;

      // Check if the user is authenticated
      if (userID != null) {
        // Determine the direction and time based on selectedOption
        String direction = ''; // Implement the logic to set the direction
        String time = ''; // Implement the logic to set the time

        switch (selectedOption) {
          case 'From ASU Gate 3':
            direction = 'From ASU Gate 3';
            time = '5:30 pm';
            break;
          case 'From ASU Gate 4':
            direction = 'From ASU Gate 4';
            time = '5:30 pm';
            break;
          case 'To ASU Gate 3':
            direction = 'To ASU Gate 3';
            time = '7:30 am';
            break;
          case 'To ASU Gate 4':
            direction = 'To ASU Gate 4';
            time = '7:30 am';
            break;
          default:
            direction = ''; // Set a default value if needed
            time = ''; // Set a default value if needed
            break;
        }

        // Format the date based on selectedDate
        String date = ''; // Initialize the date value
        if (direction.isNotEmpty && time.isNotEmpty) {
          // Set the time in the date attribute based on direction
          date = selectedDate.toLocal().toString().split(' ')[0] + ' ' + time;
        }

        // Fetch the route ID based on the selected location and driver's routes
        Map<String, String> routeDetails = await fetchRouteDetails(widget.locations.name);

        // Add the request to Firestore with updated IDs
        await FirebaseFirestore.instance.collection('Requests').add({
          'Driver ID': routeDetails['driverID'],
          'Route ID': routeDetails['routeID'],
          'User ID': userID,
          'Direction': direction,
          'status': 'pending',
          'date': date,
        });

        Navigator.pop(context); // Close the bottom sheet
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OrderHistory()),
        );
      }} catch (e) {
      print('Error creating request: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<Map<String, String>> fetchRouteDetails(String locationName) async {
    // Query Firestore to find the Route ID based on locationName and driver's routes
    Map<String, String> routeDetails = {'driverID': '', 'routeID': ''};

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Drivers')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot doc in querySnapshot.docs) {
          QuerySnapshot driverRoutesSnapshot = await doc.reference
              .collection('Routes')
              .where('name', isEqualTo: locationName)
              .get();

          if (driverRoutesSnapshot.docs.isNotEmpty) {
            // If a matching route for locationName is found under this driver
            routeDetails['driverID'] = doc.id;
            routeDetails['routeID'] = driverRoutesSnapshot.docs.first.id;
            break; // Stop iterating once a match is found
          }
        }
      }
    } catch (e) {
      print('Error fetching Route details: $e');
    }

    return routeDetails;
  }

  DateTime selectedDate = DateTime.now();
  String? dropdownValue;
  String? selectedOption;
  String? Option;

  void Options(String text) {
    Option = text;
    print("optionsssss${Option}");
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    void _showModal() {
      String description = '';
      DateTime now = DateTime.now();
      bool showError = false;
      // Define the description for each selected option
      switch (selectedOption) {
        case 'From ASU Gate 3':
          if (now.hour <= 13 && selectedDate.isBefore(now)) {
          showError = true;
          description = 'Reservation should be made prior to or at the same day of the request';
          }else if (now.hour >= 13 && selectedDate.isAtSameMomentAs(now)) {
            showError = true;
            description = 'Reservation should be before 1:00 pm of the same day of the request';
          }else if (now.hour >= 13 && selectedDate.isBefore(now)) {
            showError = true;
            description = 'Reservation should be before 1:00 pm of the same day of the request';
          }   else {
          description =
          'The pickup time is @ 5:30 pm and it must be reserved before 1 pm the same day.';
         }
          break;
        case 'From ASU Gate 4':
          if (now.hour <= 13 && selectedDate.isBefore(now)) {
            showError = true;
            description = 'Reservation should be made prior to or at the same day of the request';
          }else if (now.hour >= 13 && selectedDate.isAtSameMomentAs(now)) {
            showError = true;
            description = 'Reservation should be before 1:00 pm of the same day of the request';
          }else if (now.hour >= 13 && selectedDate.isBefore(now)) {
            showError = true;
            description = 'Reservation should be before 1:00 pm of the same day of the request';
          }   else {
            description =
            'The pickup time is @ 5:30 pm and it must be reserved before 1 pm the same day.';
          }
          break;
        case 'To ASU Gate 3':
          if (now.hour >= 22 && selectedDate.isAfter(now)) {
            showError = true;
            description = 'Reservation should be before 10:00 pm';
          } else if (now.hour <= 22 && selectedDate.isBefore(now)) {
            showError = true;
            description = 'Morning reservation should be made one day prior to the request';
          }else if (now.hour <= 22 && selectedDate.isAtSameMomentAs(now)) {
            showError = true;
            description = 'Morning reservation should be made one day prior to the request';
          }  else {
            description =
            'The pickup time is @ 5:30 pm and it must be reserved before 1 pm the same day.';
          }
          break;
        case 'To ASU Gate 4':
          if (now.hour >= 22 && selectedDate.isAfter(now)) {
            showError = true;
            description = 'Reservation should be before 10:00 pm';
          } else if (now.hour <= 22 && selectedDate.isBefore(now)) {
            showError = true;
            description = 'Morning reservation should be made one day prior to the request';
          }else if (now.hour <= 22 && selectedDate.isAtSameMomentAs(now)) {
            showError = true;
            description = 'Morning reservation should be made one day prior to the request';
          }  else {
            description =
            'The pickup time is @ 5:30 pm and it must be reserved before 1 pm the same day.';
          }
          break;
        default:
          description = '';
          break;
      }

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                height: screenHeight * 0.4,
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                color: Colors.grey.shade300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: screenHeight * 0.03),
                    Text(
                      "Selected Option: $selectedOption",
                      style: GoogleFonts.pangolin(
                        textStyle: TextStyle(
                          fontSize: screenHeight * 0.03,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      "Description: $description",
                      style: GoogleFonts.pangolin(
                        textStyle: TextStyle(
                          fontSize: screenHeight * 0.03,
                          color: Colors.grey.shade900,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.08),
                    showError
                        ? Text(
                      "Error: $description",
                      style: GoogleFonts.pangolin(
                        textStyle: TextStyle(
                          fontSize: screenHeight * 0.03,
                          color: Colors.red,
                        ),
                      ),
                    )
                        :
                    Padding(
                      padding: EdgeInsets.only(
                        left: screenWidth * 0.1,
                        right: screenWidth * 0.1,
                        bottom: screenHeight * 0.04,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(screenHeight * 0.015),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade300,
                              Colors.deepPurple.shade200
                            ],
                          ),
                        ),
                        // child: ElevatedButton(
                        //   onPressed: () {
                        //     Navigator.pop(context);
                        //     Navigator.pushReplacement(
                        //       context,
                        //       MaterialPageRoute(builder: (context) => Payment()),
                        //     );
                        //   },

                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                            });
                            createRequest();

                            Navigator.pop(context);
                          //   Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => Payment(
                          //       price: widget.locations.price, // Pass the price to the Payment page
                          //     ),
                          //   ),
                          //
                          // );
                          //   Navigator.pushReplacement(
                          //     context,
                          //     MaterialPageRoute(builder: (context) => OrderHistory()),
                          //   );
                        },
                          child: Text(
                            'Book This Ride',
                            style: GoogleFonts.pangolin(
                              textStyle: TextStyle(
                                fontSize: screenHeight * 0.035,
                                color: Colors.grey.shade900,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(screenHeight * 0.015),
                            ),
                            minimumSize: Size(
                                double.infinity, screenHeight * 0.065),
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    Widget _buildOption(String text) {
      double screenHeight = MediaQuery.of(context).size.height;
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: screenWidth * 0.05, right: screenWidth * 0.05),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedOption = text;
                  Options(text);
                  _showModal(); // Update the selected option when an option is tapped
                });
              },
              child: Text(
                text,
                style: GoogleFonts.pangolin(
                  textStyle: TextStyle(
                      fontSize: screenHeight * 0.03,
                      color: Colors.grey.shade900),
                ),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenHeight * 0.015),
                ),
                minimumSize: Size(double.infinity, screenHeight * 0.065),
                elevation: 0,
                backgroundColor: Colors.grey.shade400,
                foregroundColor: Colors.grey.shade900,
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading:
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Location()),);
              },
            ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(userId: user!.uid)), // Replace with your profile page
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => OrderHistory(), // Replace with your OrderHistory page
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
                MaterialPageRoute(builder: (context) => LoginPage(), // Replace with your OrderHistory page
                ),
              );
            },
          ),

        ],
        centerTitle: true,
        title: Text(
          "Ride Review",
          style: GoogleFonts.pangolin(
            textStyle:
            TextStyle(fontSize: screenHeight * 0.04, color: Colors.grey.shade900),
          ),
        ),

        backgroundColor: Colors.blueGrey.shade300,



      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            color: Colors.grey.shade200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.02),
                Image.asset(
                  widget.locations.imagePath,
                  width: screenHeight * 0.4,
                  height: screenHeight * 0.4,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: screenHeight * 0.03),
                Text(
                  "Location : ${widget.locations.name}",
                  style: GoogleFonts.pangolin(
                    textStyle: TextStyle(
                        fontSize: screenHeight * 0.05, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  "Price : ${widget.locations.price.toString()}",
                  style: GoogleFonts.pangolin(
                    textStyle: TextStyle(
                        fontSize: screenHeight * 0.05, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                Text(
                  "The Meeting Point is at: ",
                  style: GoogleFonts.pangolin(
                    textStyle: TextStyle(fontSize: screenHeight * 0.045),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  widget.locations.meetingpoint,
                  style: GoogleFonts.pangolin(
                    textStyle: TextStyle(fontSize: screenHeight * 0.045),
                  ),
                ),
                SizedBox(height: screenHeight * 0.08),
                Padding(
                  padding: EdgeInsets.only(
                      left: screenWidth * 0.35, right: screenWidth * 0.35),
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
                        _selectDate(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: screenHeight * 0.035,
                            color: Colors.grey.shade900,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Date',
                            style: GoogleFonts.pangolin(
                              textStyle: TextStyle(
                                  fontSize: screenHeight * 0.035,
                                  color: Colors.grey.shade900),
                            ),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenHeight * 0.015),
                        ),
                        minimumSize: Size(double.infinity, screenHeight * 0.065),
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Center(
                  child: Text("${selectedDate.toLocal()}".split(' ')[0],
                      style: GoogleFonts.pangolin(
                        textStyle: TextStyle(
                          color: Colors.grey.shade900,
                          fontSize: screenHeight * 0.04,
                        ),
                      )),
                ),
                // SizedBox(height: screenHeight * 0.04),
                Padding(
                  padding:  EdgeInsets.all(screenHeight * 0.05),
                  child: Container(
                    height: screenHeight * 0.18,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildOption('From ASU Gate 3'),
                          _buildOption('From ASU Gate 4'),
                          _buildOption('To ASU Gate 3'),
                          _buildOption('To ASU Gate 4'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
