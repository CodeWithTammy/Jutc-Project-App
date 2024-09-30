// Import statements
import 'package:flutter/material.dart'; // Flutter material design library
import 'package:email_validator/email_validator.dart'; // Email validation library
import 'package:google_fonts/google_fonts.dart'; // Google Fonts for text styling
import 'package:iconsax/iconsax.dart'; // Custom icon library
import 'package:jutcapp/Utils/navigationmenu.dart'; // Navigation menu utilities
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication library
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Cloud Firestore library
import 'package:flutter/services.dart'; // Flutter services library
import 'package:shared_preferences/shared_preferences.dart'; // Shared preferences for storing user data

// Signupscreen StatefulWidget class definition
class Signupscreen extends StatefulWidget {
  @override
  _SignupscreenState createState() => _SignupscreenState(); // Creates state for Signupscreen
}

// State class for managing stateful behavior of Signupscreen
class _SignupscreenState extends State<Signupscreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase authentication instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firebase Firestore instance
  final TextEditingController nameController = TextEditingController(); // Controller for user name input
  final TextEditingController emailController = TextEditingController(); // Controller for email input
  final TextEditingController passwordController = TextEditingController(); // Controller for password input
  final TextEditingController confirmPasswordController =
      TextEditingController(); // Controller for confirming password input
  bool isValid = true; // Flag to track if form fields are valid
  bool _passwordVisible = false; // Flag to toggle password visibility

  // Method to check if a field is empty
  Future<void> checkField(TextEditingController controller) async {
    setState(() {
      isValid = controller.text.isNotEmpty;
    });
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fields are empty")),
      );
    }
  }

  // Method to handle user sign up
  Future<void> signUp() async {
    await checkField(nameController); // Check if name field is empty
    await checkField(emailController); // Check if email field is empty
    await checkField(passwordController); // Check if password field is empty
    await checkField(confirmPasswordController); // Check if confirm password field is empty

    // Check if password and confirm password match
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    // If all fields are valid, attempt to create user
    if (isValid) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        User? user = userCredential.user;
        if (user != null) {
          // Save user details to Firestore
          await _firestore.collection("Users").doc(user.uid).set({
            "Name": nameController.text,
            "UserEmail": emailController.text,
            "isUser": "1",
          });

          // Save user details to shared preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('password', passwordController.text);
          await prefs.setString('userEmail', emailController.text);

          // Navigate to Navigationmenu after successful sign up
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Navigationmenu()),
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case "email-already-in-use":
            errorMessage = "This email address is already in use.";
            break;
          case "invalid-email":
            errorMessage = "This email address is invalid.";
            break;
          case "operation-not-allowed":
            errorMessage = "Email/password accounts are not enabled.";
            break;
          case "weak-password":
            errorMessage = "The password is too weak.";
            break;
          default:
            errorMessage = "An unknown error occurred.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Account Creation Failed: $e")),
        );
      }
    }
  }

  // Build method for building the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Scaffold background color
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              child: Image.asset('assets/busstop.png'), // Background image
            ),
            Padding(
              padding: const EdgeInsets.only(top: 312.0),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  color: Color.fromARGB(255, 255, 234, 0), // Container background color
                ),
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          'Sign Up', // Title
                          style: GoogleFonts.lexend(
                            color: const Color.fromARGB(255, 121, 82, 0),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          'Create an account in seconds!', // Subtitle
                          style: GoogleFonts.lexend(
                            color: const Color.fromARGB(255, 121, 82, 0),
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // Spacer
                      TextFormField(
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(50), // Limit input length
                        ],
                        style: TextStyle(color: Colors.black), // Text color
                        decoration: const InputDecoration(
                          hintText: "Name", // Placeholder text
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 121, 82, 0), // Placeholder color
                          ),
                          filled: true,
                          fillColor: Color.fromARGB(218, 255, 255, 255), // Text field background color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0), // Border radius
                            ),
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          prefixIcon: Icon(
                            Iconsax.user, // Custom icon
                            color: Colors.brown, // Icon color
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Name can\'t be empty'; // Validation error message
                          }
                          if (text.length < 2) {
                            return "Please enter a valid name"; // Validation error message
                          }
                          if (text.length > 49) {
                            return "Name can't be more than 50"; // Validation error message
                          }
                          return null; // No validation error
                        },
                        onChanged: (text) => setState(() {
                          nameController.text = text; // Update controller value
                        }),
                      ),
                      const SizedBox(height: 10), // Spacer
                      TextFormField(
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(100), // Limit input length
                        ],
                        style: TextStyle(color: Colors.black), // Text color
                        decoration: const InputDecoration(
                          hintText: "Email", // Placeholder text
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 121, 82, 0), // Placeholder color
                          ),
                          filled: true,
                          fillColor: Color.fromARGB(218, 255, 255, 255), // Text field background color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0), // Border radius
                            ),
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          prefixIcon: Icon(
                            Iconsax.sms, // Custom icon
                            color: Colors.brown, // Icon color
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Email can\'t be empty'; // Validation error message
                          }
                          if (text.length < 2) {
                            return "Please enter a valid email"; // Validation error message
                          }
                          if (EmailValidator.validate(text) == true) {
                            return null; // No validation error
                          }
                          if (text.length > 99) {
                            return "Email can't be more than 100"; // Validation error message
                          }
                          return "Please enter a valid email address"; // Validation error message
                        },
                        onChanged: (text) => setState(() {
                          emailController.text = text; // Update controller value
                        }),
                      ),
                      const SizedBox(height: 10), // Spacer
                      TextFormField(
                        obscureText: !_passwordVisible, // Toggle password visibility
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(50), // Limit input length
                        ],
                        style: TextStyle(color: Colors.black), // Text color
                        decoration: InputDecoration(
                          hintText: "Password", // Placeholder text
                          hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 121, 82, 0), // Placeholder color
                          ),
                          filled: true,
                          fillColor: const Color.fromARGB(218,                          255, 255, 255), // Text field background color
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0), // Border radius
                            ),
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Iconsax.lock, // Custom icon
                            color: Colors.brown, // Icon color
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            color: Colors.grey, // Icon color
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible; // Toggle password visibility
                              });
                            },
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Password can\'t be empty'; // Validation error message
                          }
                          if (text.length < 6) {
                            return "Password must be at least 6 characters long"; // Validation error message
                          }
                          if (text.length > 49) {
                            return "Password can't be more than 50 characters"; // Validation error message
                          }
                          return null; // No validation error
                        },
                        onChanged: (text) => setState(() {
                          passwordController.text = text; // Update controller value
                        }),
                      ),
                      const SizedBox(height: 10), // Spacer
                      TextFormField(
                        obscureText: !_passwordVisible, // Toggle password visibility
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(50), // Limit input length
                        ],
                        style: TextStyle(color: Colors.black), // Text color
                        decoration: InputDecoration(
                          hintText: "Confirm Password", // Placeholder text
                          hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 121, 82, 0), // Placeholder color
                          ),
                          filled: true,
                          fillColor: const Color.fromARGB(218, 255, 255, 255), // Text field background color
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0), // Border radius
                            ),
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Iconsax.lock, // Custom icon
                            color: Colors.brown, // Icon color
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            color: Colors.grey, // Icon color
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible; // Toggle password visibility
                              });
                            },
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Confirm Password can\'t be empty'; // Validation error message
                          }
                          if (text != passwordController.text) {
                            return "Passwords do not match"; // Validation error message
                          }
                          return null; // No validation error
                        },
                        onChanged: (text) => setState(() {
                          confirmPasswordController.text = text; // Update controller value
                        }),
                      ),
                      const SizedBox(height: 10), // Spacer
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: signUp, // Call signUp method on button press
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 121, 82, 0), // Button background color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0), // Button border radius
                            ),
                          ),
                          child: const Text(
                            'Sign Up', // Button text
                            style: TextStyle(
                              color: Colors.white, // Text color
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10), // Spacer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account?", // Text
                            style: TextStyle(
                              color: Color.fromARGB(255, 121, 82, 0), // Text color
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Navigate back to previous screen
                            },
                            child: const Text(
                              'Login here', // Text
                              style: TextStyle(
                                color: Color.fromARGB(255, 121, 82, 0), // Text color
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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

