import 'package:flutter/material.dart'; // Flutter material library
import 'package:google_fonts/google_fonts.dart'; // Google Fonts for text styling
import 'package:iconsax/iconsax.dart'; // Iconsax icon library
import 'package:jutcapp/Utils/navigationmenu.dart'; // Navigation menu utility
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication library
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore library
import 'package:flutter/services.dart'; // Flutter services library for input validation
import 'package:jutcapp/driver/driverlogin.dart'; // Driver login screen
import 'package:shared_preferences/shared_preferences.dart'; // Shared preferences for storing user details

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  _LoginscreenState createState() => _LoginscreenState(); // Stateful widget for login screen
}

class _LoginscreenState extends State<Loginscreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase authentication instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance
  final TextEditingController emailController = TextEditingController(); // Controller for email input field
  final TextEditingController passwordController = TextEditingController(); // Controller for password input field
  bool isValid = true; // Flag to track form validation status
  bool _passwordVisible = false; // Flag to toggle password visibility

  // Function to check if text field is empty
  Future<void> checkField(TextEditingController controller) async {
    setState(() {
      isValid = controller.text.isNotEmpty; // Check if field is not empty
    });
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar( // Show snack bar if field is empty
        const SnackBar(content: Text("Fields are empty")),
      );
    }
  }

  // Function to handle sign in process
  Future<void> signIn() async {
    await checkField(emailController); // Check email field
    await checkField(passwordController); // Check password field

    if (isValid) { // Proceed if fields are valid
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword( // Sign in with email and password
          email: emailController.text,
          password: passwordController.text,
        );

        User? user = userCredential.user; // Get user details
        if (user != null) {
          // Fetch user details from shared preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? userName = prefs.getString('password'); // Get saved password
          String? userEmail = prefs.getString('userEmail'); // Get saved email

          if (userName != null && userEmail != null) {
            Navigator.pushAndRemoveUntil( // Navigate to main screen on successful login
              context,
              MaterialPageRoute(builder: (context) => const Navigationmenu()),
              (route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar( // Show snack bar if user details not found
              const SnackBar(content: Text("User details not found")),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case "invalid-email":
            errorMessage = "Invalid email address format"; // Invalid email format error
            break;
          case "user-not-found":
          case "wrong-password":
            errorMessage = "Invalid email or password"; // Invalid email or password error
            break;
          default:
            errorMessage = "An unknown error occurred"; // Unknown error
            break;
        }
        ScaffoldMessenger.of(context).showSnackBar( // Show error message in snack bar
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar( // Show generic login failed error
          SnackBar(content: Text("Login Failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height; // Get screen height
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      body: SingleChildScrollView( // Scrollable view for smaller screens
        child: Stack(
          children: [
            Container(
              child: Image.asset('assets/busstop.png'), // Background image
            ),
            Padding(
              padding: const EdgeInsets.only(top: 312.0), // Padding for main content
              child: Container(
                height: screenHeight * 0.62, // Height of container
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only( // Rounded corners for top
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  color: Color.fromARGB(255, 255, 234, 0), // Background color
                ),
                width: double.infinity, // Full width
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 50), // Padding inside container
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          'Login', // Title text
                          style: GoogleFonts.lexend( // Google font styling
                            color: const Color.fromARGB(255, 121, 82, 0), // Text color
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          'Sign in to your account!', // Subtitle text
                          style: GoogleFonts.lexend( // Google font styling
                            color: const Color.fromARGB(255, 121, 82, 0), // Text color
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // Spacer
                      TextFormField(
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(100), // Limit email length
                        ],
                        style: const TextStyle(color: Colors.black), // Text color
                        decoration: const InputDecoration( // Input decoration
                          hintText: "Email", // Placeholder text
                          hintStyle: TextStyle( // Placeholder style
                            color: Color.fromARGB(255, 121, 82, 0),
                          ),
                          filled: true, // Fill background
                          fillColor: Color.fromARGB(218, 255, 255, 255), // Background color
                          border: OutlineInputBorder( // Border style
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0), // Rounded corners
                            ),
                            borderSide: BorderSide( // No visible border
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          prefixIcon: Icon( // Icon before text field
                            Iconsax.sms, // Custom icon
                            color: Colors.brown, // Icon color
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction, // Validate on user interaction
                        validator: (text) { // Validation function
                          if (text == null || text.isEmpty) {
                            return 'Email can\'t be empty'; // Error message if empty
                          }
                          if (text.length < 2) {
                            return "Please enter a valid email"; // Error message for invalid email
                          }
                          if (text.length > 99) {
                            return "Email can't be more than 100"; // Error message if email too long
                          }
                          return null; // No error
                        },
                        onChanged: (text) => setState(() { // Update email text
                          emailController.text = text;
                        }),
                      ),
                      const SizedBox(height: 30), // Spacer
                      TextFormField(
                        obscureText: !_passwordVisible, // Toggle password visibility
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(50), // Limit password length
                        ],
                        style: const TextStyle(color: Colors.black), // Text color
                        decoration: InputDecoration( // Input decoration
                          hintText: "Password", // Placeholder text
                          hintStyle: const TextStyle( // Placeholder style
                            color: Color.fromARGB(255, 121, 82, 0),
                          ),
                          filled: true, // Fill background
                          fillColor: const Color.fromARGB(218, 255, 255, 255), // Background color
                          border: const OutlineInputBorder( // Border style
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0), // Rounded corners
                            ),
                            borderSide: BorderSide( // No visible border
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          prefixIcon: const Icon( // Icon before text field
                            Iconsax.lock, // Custom icon
                            color: Colors.brown, // Icon color
                          ),
                          suffixIcon: IconButton( // Icon after text field (toggle password visibility)
                            icon: Icon(
                              _passwordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            color: Colors.grey, // Icon color
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible; // Toggle password visibility
                              });
                            },
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction, // Validate on user interaction
                        validator: (text) { // Validation function
                          if (text == null || text.isEmpty) {
                            return 'Password can\'t be empty'; // Error message if empty
                          }
                          if (text.length < 6) {
                            return "Password must be at least 6 characters long"; // Error message for short password
                          }
                          if (text.length > 49) {
                            return "Password can't be more than 50 characters"; // Error message for long password
                          }
                          return null; // No error
                        },
                        onChanged: (text) => setState(() { // Update password text
                          passwordController.text = text;
                        }),
                      ),
                      const SizedBox(height: 50), // Spacer
                      SizedBox(                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: signIn, // Call signIn function on button press
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 121, 82, 0), // Button background color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0), // Rounded corners
                            ),
                          ),
                          child: const Text(
                            'Sign In', // Button text
                            style: TextStyle(
                              color: Colors.white, // Text color
                              fontSize: 18, // Text size
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10), // Spacer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?", // Text before sign up button
                            style: TextStyle(
                              color: Color.fromARGB(255, 121, 82, 0), // Text color
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Navigate back to previous screen
                            },
                            child: const Text(
                              'Sign Up here', // Sign up button text
                              style: TextStyle(
                                color: Color.fromARGB(255, 121, 82, 0), // Text color
                                fontWeight: FontWeight.bold, // Bold text
                              ),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Driverlogin())); // Navigate to driver login screen
                        },
                        child: const Text(
                          'Login as driver', // Text for driver login link
                          style: TextStyle(
                            fontSize: 16, // Text size
                            decoration: TextDecoration.underline, // Underline decoration
                            decorationColor: Colors.black, // Decoration color
                            color: Colors.black, // Text color
                            fontWeight: FontWeight.bold, // Bold text
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

