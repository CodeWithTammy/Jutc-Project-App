// Import statements
import 'package:flutter/material.dart'; // Flutter material design library
import 'package:jutcapp/Userscreens/usersignupscreen.dart'; // Importing Signupscreen class
import 'package:jutcapp/screens/loginscreen.dart'; // Importing Loginscreen class

// Optionscreen StatefulWidget class definition
class Optionscreen extends StatefulWidget {
  const Optionscreen({super.key}); // Constructor for Optionscreen widget

  @override
  State<Optionscreen> createState() => _OptionscreenState(); // Creates state for Optionscreen
}

// State class for managing stateful behavior of Optionscreen
class _OptionscreenState extends State<Optionscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Scaffold background color
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Center(
            child: Column(
              children: <Widget>[
                Container(
                  width: 200,
                  height: 200,
                  child: Image.asset('assets/logo.png'), // Displays app logo
                ),
                const SizedBox(height: 10), // Spacer for separation
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 300,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Signupscreen(), // Navigates to Signupscreen
                            ),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: const Color.fromARGB(255, 255, 234, 0), // Button background color
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // Spacer for separation
                    Container(
                      width: 300,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Loginscreen(), // Navigates to Loginscreen
                            ),
                          );
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(
                              color: Colors.black, // Border color
                              width: 2, // Border width
                            ),
                          ),
                          backgroundColor: Colors.white, // Button background color
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50), // Spacer for separation
                Flexible(
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/busdriver.png'), // Displays an image of a bus driver
                        fit: BoxFit.contain,
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
