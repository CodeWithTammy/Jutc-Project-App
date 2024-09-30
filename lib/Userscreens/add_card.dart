import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart'; // Import for CreditCardWidget and CreditCardForm
import 'package:get/get.dart'; // Import for Get package
import 'package:jutcapp/Utils/navigationmenu.dart'; // Import for navigation
import 'package:jutcapp/Utils/auth_controller.dart'; // Import for AuthController

class Addmypayment extends StatefulWidget {
  const Addmypayment({super.key});

  @override
  State<Addmypayment> createState() => _AddmypaymentState();
}

class _AddmypaymentState extends State<Addmypayment> {
  String cardNumber = ''; // Holds the entered card number
  String expiryDate = ''; // Holds the entered expiry date
  String cardHolderName = ''; // Holds the entered card holder's name
  String cvvCode = ''; // Holds the entered CVV code
  bool isCvvFocused = false; // Tracks if CVV field is focused
  bool useBackgroundImage = false; // Flag for background image usage
  bool useFloatingAnimation = true; // Flag for floating animation
  final OutlineInputBorder border = OutlineInputBorder( // Border style for form fields
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(0.7),
      width: 2.0,
    ),
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>(); // Form key for form validation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Bank Card'), // App bar title
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.headphones, color: Colors.black),
            onPressed: () {
              // Handle notification icon press
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 225, 0), // Background color of app bar
      ),
      resizeToAvoidBottomInset: false, // Ensures the screen doesn't resize when the keyboard appears
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Stack(
                children: [
                  ClipPath(
                    clipper: OvalClipper(), // Custom clipper for oval shape in the background
                    child: Container(
                      height: 260,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 255, 225, 0), // Oval background color
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 38.0),
                    child: CreditCardWidget(
                      enableFloatingCard: useFloatingAnimation, // Enable floating animation
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      bankName: 'Axis Bank',
                      showBackView: isCvvFocused, // Show back view when CVV is focused
                      obscureCardNumber: true, // Obscure card number for security
                      obscureCardCvv: true, // Obscure CVV code for security
                      isHolderNameVisible: true, // Show card holder's name
                      cardBgColor: Colors.black, // Card background color
                      isSwipeGestureEnabled: true, // Enable swipe gesture
                      onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
                      customCardTypeIcons: <CustomCardTypeIcon>[
                        CustomCardTypeIcon(
                          cardType: CardType.mastercard, // Custom icon for Mastercard type
                          cardImage: Image.asset(
                            'assets/mastercard.png',
                            height: 48,
                            width: 48,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    CreditCardForm(
                      formKey: formKey,
                      obscureCvv: true, // Obscure CVV input
                      obscureNumber: true, // Obscure card number input
                      cardNumber: cardNumber,
                      cvvCode: cvvCode,
                      isHolderNameVisible: true, // Show card holder's name input
                      isCardNumberVisible: true, // Show card number input
                      isExpiryDateVisible: true, // Show expiry date input
                      cardHolderName: cardHolderName,
                      expiryDate: expiryDate,
                      inputConfiguration: const InputConfiguration(
                        cardNumberDecoration: InputDecoration(
                          labelText: 'Card Number',
                          labelStyle: TextStyle(color: Colors.black),
                          hintText: 'XXXX XXXX XXXX XXXX',
                          hintStyle: TextStyle(color: Colors.grey), // Optional: change hint text color
                          filled: true,
                          fillColor: Colors.white, // Optional: change background color of input
                          border: OutlineInputBorder(), // Optional: add border to input
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 41, 41, 41)), // Optional: change border color when focused
                          ),
                          contentPadding: EdgeInsets.all(10),
                          counterText: '', // Optional: hide counter text
                        ),
                        expiryDateDecoration: InputDecoration(
                          labelText: 'Expired Date',
                          labelStyle: TextStyle(color: Colors.black),
                          hintText: 'XX/XX',
                          hintStyle: TextStyle(color: Colors.grey), // Optional: change hint text color
                          filled: true,
                          fillColor: Colors.white, // Optional: change background color of input
                          border: OutlineInputBorder(), // Optional: add border to input
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 41, 41, 41)), // Optional: change border color when focused
                          ),
                          contentPadding: EdgeInsets.all(10),
                          counterText: '', // Optional: hide counter text
                        ),
                        cvvCodeDecoration: InputDecoration(
                          labelText: 'CVV',
                          labelStyle: TextStyle(color: Colors.black),
                          hintText: 'XXX',
                          hintStyle: TextStyle(color: Colors.grey), // Optional: change hint text color
                          filled: true,
                          fillColor: Colors.white, // Optional: change background color of input
                          border: OutlineInputBorder(), // Optional: add border to input
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 41, 41, 41)), // Optional: change border color when focused
                          ),
                          contentPadding: EdgeInsets.all(10),
                          counterText: '', // Optional: hide counter text
                        ),
                        cardHolderDecoration: InputDecoration(
                          labelText: 'Card Holder',
                          labelStyle: TextStyle(color: Colors.black),
                          hintStyle: TextStyle(color: Colors.grey), // Optional: change hint text color
                          filled: true,
                          fillColor: Colors.white, // Optional: change background color of input
                          border: OutlineInputBorder(), // Optional: add border to input
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 41, 41, 41)), // Optional: change border color when focused
                          ),
                          contentPadding: EdgeInsets.all(10),
                          counterText: '', // Optional: hide counter text
                        ),
                      ),
                      onCreditCardModelChange: onCreditCardModelChange,
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),
                    Container(
                      width: 300,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 20,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28.0),
                          ),
                          backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Button background color
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          child: const Text(
                            'Save', // Button text
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'halter',
                              fontSize: 14,
                              package: 'flutter_credit_card', // Optional: specify package for font family
                            ),
                          ),
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) { // Validate form input
                            try {
                              await Get.find<AuthController>().storeUserCard( // Store user card details
                                cardNumber, 
                                expiryDate, 
                                cvvCode, 
                                cardHolderName
                              );
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Navigationmenu())); // Navigate to menu screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Card was successfully added")), // Show success message
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("This card has already been added")), // Show error message if card already exists
                              );
                            }
                          } else {
                            print('invalid!');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber; // Update card number
      expiryDate = creditCardModel.expiryDate; // Update expiry date
      cardHolderName = creditCardModel.cardHolderName; // Update card holder's name
      cvvCode = creditCardModel.cvvCode; // Update CVV code
      isCvvFocused = creditCardModel.isCvvFocused; // Update CVV focus status
    });
  }
}

// Class to shape the oval clip
class OvalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width / 2, size.height, size.width, size.height - 150);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
