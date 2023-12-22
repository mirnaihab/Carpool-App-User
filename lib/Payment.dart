import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:project/LoginPage.dart';
import 'package:project/OrderHistory.dart';
import 'Location.dart';
import 'firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Payment extends StatefulWidget {
  final String requestId;
  final int price;

  Payment({required this.requestId, required this.price});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  bool useFloatingAnimation = true;
  final OutlineInputBorder border = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(0.7),
      width: 2.0,
    ),
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  User? user = FirebaseAuth.instance.currentUser;
  void updateRequestStatus() async {
    try {
      // Update the Firestore document with the provided request ID to 'paid'
      await FirebaseFirestore.instance
          .collection('Requests')
          .doc(widget.requestId) // Use the provided request ID
          .update({'status': 'paid'});
      print("statttttttt");
      // Navigate to the OrderHistory page after the status is updated
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OrderHistory()),
      );
    } catch (error) {
      print("Error updating request status: $error");
      // Handle error if update fails
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: const TextTheme(
          // Text style for text fields' input.
          titleMedium: TextStyle(color: Colors.grey, fontSize: 18),
        ),
        // Decoration theme for the text fields.
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: const TextStyle(color: Colors.grey),
          labelStyle: const TextStyle(color: Colors.grey),
          focusedBorder: border,
          enabledBorder: border,
        ),
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        // appBar: AppBar(
        //   leading: IconButton(
        //     icon: Icon(Icons.arrow_back),
        //     onPressed: () {
        //       Navigator.pop(context); // Navigate back to the previous screen
        //     },
        //   ),
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
            "Payment",
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
        ),
        body: ListView(
          // builder: (BuildContext context) {
          //   return Container(
              children: [ Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[

                    CreditCardWidget(
                      enableFloatingCard: useFloatingAnimation,
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      bankName: 'Bank X',
                      frontCardBorder: Border.all(color: Colors.grey),
                      backCardBorder:  Border.all(color: Colors.grey),
                      showBackView: isCvvFocused,
                      obscureCardNumber: true,
                      obscureCardCvv: true,
                      isHolderNameVisible: true,
                      isSwipeGestureEnabled: true,
                      onCreditCardWidgetChange:
                          (CreditCardBrand creditCardBrand) {},
                      customCardTypeIcons: <CustomCardTypeIcon>[
                        CustomCardTypeIcon(
                          cardType: CardType.mastercard,
                          cardImage: Image.asset(
                            'assets/Mastercard.png',
                            height: 48,
                            width: 48,
                          ),
                        ),
                      ],
                    ),
                    // Expanded(
                      SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          children: <Widget>[
                            CreditCardForm(
                              formKey: formKey,
                              obscureCvv: true,
                              obscureNumber: true,
                              cardNumber: cardNumber,
                              cvvCode: cvvCode,
                              isHolderNameVisible: true,
                              isCardNumberVisible: true,
                              isExpiryDateVisible: true,
                              cardHolderName: cardHolderName,
                              expiryDate: expiryDate,
                              inputConfiguration: const InputConfiguration(
                                cardNumberDecoration: InputDecoration(
                                  labelText: 'Card Number',
                                  hintText: 'XXXX XXXX XXXX XXXX',
                                  labelStyle:  TextStyle(color: Colors.black54), // Set label color
                                  hintStyle: TextStyle(color: Colors.black54),

                                ),
                                expiryDateDecoration: InputDecoration(
                                  labelText: 'Expired Date',
                                  hintText: 'XX/XX',
                                  labelStyle: TextStyle(color: Colors.black54), // Set label color
                                  hintStyle: TextStyle(color: Colors.black54),
                                ),
                                cvvCodeDecoration: InputDecoration(
                                  labelText: 'CVV',
                                  hintText: 'XXX',
                                  labelStyle: TextStyle(color: Colors.black54), // Set label color
                                  hintStyle: TextStyle(color: Colors.black54),
                                ),
                                cardHolderDecoration: InputDecoration(
                                  labelText: 'Card Holder',
                                  labelStyle: TextStyle(color: Colors.black54), // Set label color
                                  hintStyle: TextStyle(color: Colors.black54),
                                ),
                              ),
                              onCreditCardModelChange: onCreditCardModelChange,
                            ),
                            SizedBox(height: screenHeight*0.07),
                            Padding(
                              padding:EdgeInsets.only(left: screenWidth*0.06, right: screenWidth*0.06, bottom: screenHeight*0.03),
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
                                    updateRequestStatus();
                                    // Navigator.pushReplacement(
                                    //   context,
                                    //   MaterialPageRoute(builder: (context) => OrderHistory()),
                                    // );
                                  },
                                  // child: Text(
                                  //   'Validate',
                                  //   style: GoogleFonts.pangolin(
                                  //     textStyle: TextStyle(fontSize: screenHeight * 0.035, color: Colors.grey.shade900),
                                  //   ),
                                  // ),
                                  child: Text(
                                    'Validate & Pay: ${widget.price}',
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
                                    foregroundColor: Colors.transparent, // Set the button's splash color to transparent
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                  ],
                ),
              ),

            ),
    ]

        ),
        ),
    );
  }

  // void _onValidate() {
  //   if (formKey.currentState?.validate() ?? false) {
  //     print('valid!');
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => StatusHistory()),
  //     );
  //   } else {
  //     print('invalid!');
  //   }
  // }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}