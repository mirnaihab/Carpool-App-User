import 'package:flutter/material.dart';
import 'package:project/Location.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/LoginPage.dart';
import 'firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class Request {
  final String direction;
  final String status;
  final String date;
  final String routeID;
  final String driverID;

  Request({
    required this.direction,
    required this.status,
    required this.date,
    required this.routeID,
    required this.driverID,
  });
}


class OrderHistory extends StatefulWidget {
  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {

  late User? _user;
  late List<Request> _requests;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      fetchRequests();
    }
  }

  void fetchRequests() async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
        .collection('Requests')
        .where('User ID', isEqualTo: _user!.uid)
        .get();

    setState(() {
      _requests = snapshot.docs.map((doc) {
        return Request(
          direction: doc['Direction'],
          status: doc['status'],
          date: doc['date'],
          routeID: doc['Route ID'],
          driverID: doc['Driver ID'],
        );
      }).toList();
    });
  }

  void cancelRequest(int index) async {
    final request = _requests[index]; // Get the request data

    try {
      // Construct the query to find and delete the request
      await FirebaseFirestore.instance
          .collection('Requests')
          .where('Driver ID', isEqualTo: request.driverID)
          .where('Route ID', isEqualTo: request.routeID)
          .where('Direction', isEqualTo: request.direction)
          .where('status', isEqualTo: request.status)
          .where('date', isEqualTo: request.date)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final docID = snapshot.docs.first.id;
          FirebaseFirestore.instance.collection('Requests').doc(docID).delete();
        }
      });

      setState(() {
        _requests.removeAt(index); // Remove from local state
      });
    } catch (error) {
      print("Error removing request: $error");
      // Handle error if deletion fails
    }
  }

  void _showRemoveDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade200,
          title: Text('Cancel Request' ,
              style: GoogleFonts.pangolin(
              textStyle: TextStyle(
                fontSize: 25,
                color: Colors.grey.shade900,
              ),
            ),),
          content: Text('Are you sure you want to cancel this request?',
            style: GoogleFonts.pangolin(
              textStyle: TextStyle(
                fontSize: 19,
                color: Colors.grey.shade900,
              ),
            ),),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade800),
                  color: Colors.grey.shade200,
                ),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Text(
                  'No',
                  style: GoogleFonts.pangolin(
                    textStyle: TextStyle(
                      fontSize: 19,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                cancelRequest(index);
                Navigator.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade800),
                  color: Colors.grey.shade200,
                ),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Text(
                  'Yes',
                  style: GoogleFonts.pangolin(
                    textStyle: TextStyle(
                      fontSize: 19,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
        double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
        // bool showDetailsButton = _requests[index].status == 'Accepted';

        void _showModal(BuildContext context, Request request) {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return SingleChildScrollView(
                    child: Container(
                      height: screenHeight * 0.7,
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      color: Colors.grey.shade300,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: screenHeight * 0.03),
                          FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            future: FirebaseFirestore.instance
                                .collection('Drivers')
                                .doc(request.driverID)
                                .get(),
                            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }
                              if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                                return Text('Error fetching driver data');
                              }
                              var driverData = snapshot.data!.data();
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Driver's Name: ${driverData?['username'] ?? 'N/A'}\n"
                                        "Phone Number: 0${driverData?['phone'] ?? 'N/A'}\n"
                                        "Car: ${driverData?['cartype'] ?? 'N/A'}\n"
                                        "Plate Number: ${driverData?['platenumber'] ?? 'N/A'}",
                                    style: GoogleFonts.pangolin(
                                      textStyle: TextStyle(
                                        fontSize: screenHeight * 0.04,

                                        color: Colors.grey.shade900,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.05),
                                  Center(
                                    child: Image.asset(
                                      "assets/profile.png",
                                      width: screenWidth * 0.5,
                                      height: screenHeight * 0.28,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),

                                  // Add more content here as needed
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Location()),);
          },
        ),
        centerTitle: true,
        title: Text(
          "Requests",
          style: GoogleFonts.pangolin(
            textStyle: TextStyle(fontSize: screenHeight * 0.04, color: Colors.grey.shade900),
          ),
        ),
        backgroundColor: Colors.blueGrey.shade300,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()), // Replace with your profile page
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
      ),
      backgroundColor: Colors.grey.shade200,
      body: _requests == null ?
      Center(child: CircularProgressIndicator()):
      ListView.builder(
        itemCount: _requests.length,
        itemBuilder: (BuildContext context, int index) {
          bool showDetailsButton = _requests[index].status == 'approved';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),

                tileColor: Colors.grey.shade300,

                title:
                Text(
                  _requests[index].direction,
                  style: TextStyle(
                    fontSize: 19,
                    color: Colors.grey.shade900,
                  ),
                ),
                subtitle:
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: ${_requests[index].date}',
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.grey.shade900,
                          ),
                        ),
                        FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          future: FirebaseFirestore.instance
                              .collection('Drivers')
                              .doc(_requests[index].driverID)
                              .collection('Routes')
                              .doc(_requests[index].routeID)
                              .get(),
                          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                              return Text('Error fetching data');
                            }
                            var routeData = snapshot.data!.data();
                            return Text('Route: ${routeData?['name']} \n Meeting Point: \n${routeData?['meetingpoint']}\n '
                                'Price: ${routeData?['price']}',
                              style: GoogleFonts.pangolin(
                                textStyle: TextStyle(
                                  fontSize: 17,
                                  color: Colors.grey.shade900,
                                ),
                              ),);
                          },
                        ),
                        Row(
                          children: [
                            Text('Status: ',
                              style: GoogleFonts.pangolin(
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade900,
                                ),
                              ),),
                            Image.asset(
                              'assets/${_requests[index].status.toLowerCase()}.png',
                              width: 30,
                              height: 30,
                              // height: screenHeight * 0.05,
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(width: screenWidth*0.12),
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top:0, bottom: 20),
                          child: SizedBox(
                            height: screenHeight*0.05,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(screenHeight * 0.025),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.blue.shade300, Colors.deepPurple.shade200],
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  _showRemoveDialog(index);
                                  // setState(() {
                                  //   orders.removeAt(index);
                                  // });
                                },
                                child: Text(
                                  'cancel',
                                  style: GoogleFonts.pangolin(
                                    textStyle: TextStyle(fontSize: screenHeight * 0.03, color: Colors.grey.shade900),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(screenHeight * 0.015),
                                  ),
                                  minimumSize: Size(0, screenHeight * 0.005),
                                  elevation: 0, // Optional: Set elevation to 0 for a flat design
                                  backgroundColor: Colors.transparent, // Set the button's background to transparent
                                  foregroundColor: Colors.transparent,  // Set the button's splash color to transparent
                                ),
                              ),
                            ),
                          ),
                        ),
                        showDetailsButton ?
                        SizedBox(
                          height: screenHeight*0.05,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(screenHeight * 0.025),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.blue.shade300, Colors.deepPurple.shade200],
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                               _showModal(context, _requests[index]);
                              },
                              child: Text(
                                'Details',
                                style: GoogleFonts.pangolin(
                                  textStyle: TextStyle(fontSize: screenHeight * 0.03, color: Colors.grey.shade900),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(screenHeight * 0.015),
                                ),
                                minimumSize: Size(0, screenHeight * 0.005),
                                elevation: 0, // Optional: Set elevation to 0 for a flat design
                                backgroundColor: Colors.transparent, // Set the button's background to transparent
                                foregroundColor: Colors.transparent,  // Set the button's splash color to transparent
                              ),
                            ),
                          ),
                        ) :
                        SizedBox(height: 10),
                      ],
                    ),
                  ],
                ),
                // trailing:

                onTap: () {
                  // Handle tile tap if needed
                },
              ),
            ),
          );
        },
      )
    );
  }
}



//   List<Order> orders = [
//     Order("El Abasseya", "28/11/2023", "assets/finish.png", "Returning", "Finished"),
//     Order("Abdu-Basha", "1/12/2023", "assets/declined.png", "going", "Declined"),
//     Order("Heliopolis", "5/12/2023", "assets/approved.png", "Going", "Approved"),
//     Order("Nasr City", "10/12/2023", "assets/pending.png", "Returning", "Pending"),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     double screenWidth = MediaQuery.of(context).size.width;
//
//     void _showModal(BuildContext context, Order order) {
//       showModalBottomSheet(
//         context: context,
//         builder: (BuildContext context) {
//           return StatefulBuilder(
//             builder: (BuildContext context, StateSetter setState) {
//               return SingleChildScrollView(
//                 child: Container(
//                   height: screenHeight * 0.7,
//                   padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
//                   color: Colors.grey.shade300,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       SizedBox(height: screenHeight * 0.03),
//                       Text(
//                         "Your Driver's Name is: Mirna.\n"
//                             "Phone Number: 01535544854\n"
//                             "                   Car: Toyota \n"
//                             "                Plate: AAL 252",
//                         style: GoogleFonts.pangolin(
//                           textStyle: TextStyle(
//                             fontSize: screenHeight * 0.04,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.grey.shade900,
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: screenHeight * 0.05,),
//                       Image.asset(
//                         "assets/profile.png",
//                         width: screenWidth * 0.5,
//                         height: screenHeight * 0.25,
//                         fit: BoxFit.cover,
//                       ),
//                       SizedBox(height: screenHeight * 0.02),
//                       Text(
//                         "This trip is ${order.direction}\n"
//                             "Status : ${order.status}",
//                         style: GoogleFonts.pangolin(
//                           textStyle: TextStyle(
//                             fontSize: screenHeight * 0.04,
//                             color: Colors.grey.shade900,
//                           ),
//                         ),
//                       ),
//                       // Add more content here as needed
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       );
//     }
//
//
//     return Scaffold(
//       resizeToAvoidBottomInset:false,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Location()),);
//           },
//         ),
//         centerTitle: true,
//         title: Text(
//           "Orders",
//           style: GoogleFonts.pangolin(
//             textStyle: TextStyle(fontSize: screenHeight * 0.04, color: Colors.grey.shade900),
//           ),
//         ),
//         backgroundColor: Colors.blueGrey.shade300,
//         actions: [
//           IconButton(
//             icon: Icon(Icons.account_circle),
//             onPressed: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => ProfilePage()), // Replace with your profile page
//               );
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () {
//               FirebaseAuth.instance.signOut();
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => LoginPage(), // Replace with your OrderHistory page
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       backgroundColor: Colors.grey.shade200,
//       body: ListView.builder(
//         itemCount: orders.length,
//         itemBuilder: (context, index) {
//           return Padding(
//               padding: const EdgeInsets.symmetric(vertical: 3.0),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(screenHeight * 0.03), // Adjust the vertical padding as needed
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey),
//                     color: Colors.grey.shade300, // Set darker background color here
//                   ),
//                   child: ListTile(
//                     title: Row(
//                       children: [
//                         SizedBox(
//                           width: screenWidth*0.4,
//                           child: Column(
//                             children: [
//                               Text(
//                                 orders[index].location,
//                                 style: GoogleFonts.pangolin(
//                                   textStyle: TextStyle(
//                                     fontSize: screenHeight * 0.04,
//                                     color: Colors.grey.shade900,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(width: screenHeight * 0.01),
//
//                               Text(
//                                 "${orders[index].date}\n"
//                                     "Status: ",
//                                 style: GoogleFonts.pangolin(
//                                   textStyle: TextStyle(
//                                     fontSize: screenHeight * 0.034,
//                                     color: Colors.grey.shade900,
//                                   ),
//                                 ),
//                               ),
//                               Image.asset(
//                                 orders[index].Statuslogo,
//                                 width: screenWidth * 0.1,
//                                 height: screenHeight * 0.05,
//                                 fit: BoxFit.cover,
//                               ),
//                               SizedBox(height:screenHeight*0.01),
//                             ],
//                           ),
//                         ),
//                         SizedBox(width: screenWidth*0.2),
//                         SizedBox(
//                           height: screenHeight * 0.12,
//                           child:
//                           Column(
//                             children: [
//                               SizedBox(
//                                 height: screenHeight*0.05,
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(screenHeight * 0.025),
//                                     gradient: LinearGradient(
//                                       begin: Alignment.topLeft,
//                                       end: Alignment.bottomRight,
//                                       colors: [Colors.blue.shade300, Colors.deepPurple.shade200],
//                                     ),
//                                   ),
//                                   child: ElevatedButton(
//                                     onPressed: () {
//                                       setState(() {
//                                         orders.removeAt(index);
//                                       });
//                                     },
//                                     child: Text(
//                                       'cancel',
//                                       style: GoogleFonts.pangolin(
//                                         textStyle: TextStyle(fontSize: screenHeight * 0.03, color: Colors.grey.shade900),
//                                       ),
//                                     ),
//                                     style: ElevatedButton.styleFrom(
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(screenHeight * 0.015),
//                                       ),
//                                       minimumSize: Size(0, screenHeight * 0.005),
//                                       elevation: 0, // Optional: Set elevation to 0 for a flat design
//                                       backgroundColor: Colors.transparent, // Set the button's background to transparent
//                                       foregroundColor: Colors.transparent,  // Set the button's splash color to transparent
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: screenHeight*0.02),
//                               SizedBox(
//                                 height: screenHeight*0.05,
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(screenHeight * 0.025),
//                                     gradient: LinearGradient(
//                                       begin: Alignment.topLeft,
//                                       end: Alignment.bottomRight,
//                                       colors: [Colors.blue.shade300, Colors.deepPurple.shade200],
//                                     ),
//                                   ),
//                                   child: ElevatedButton(
//                                     onPressed: () {
//                                       _showModal(context, orders[index]);
//                                     },
//                                     child: Text(
//                                       'Details',
//                                       style: GoogleFonts.pangolin(
//                                         textStyle: TextStyle(fontSize: screenHeight * 0.03, color: Colors.grey.shade900),
//                                       ),
//                                     ),
//                                     style: ElevatedButton.styleFrom(
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(screenHeight * 0.015),
//                                       ),
//                                       minimumSize: Size(0, screenHeight * 0.005),
//                                       elevation: 0, // Optional: Set elevation to 0 for a flat design
//                                       backgroundColor: Colors.transparent, // Set the button's background to transparent
//                                       foregroundColor: Colors.transparent,  // Set the button's splash color to transparent
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                       ],
//                     ),
//
//                   ),
//                 ),
//               )
//           );
//         },
//       ),
//     );
//   }
// }
