import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jutcapp/Utils/drivernavmenu.dart';
import 'package:jutcapp/Utils/navigationmenu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class Driverlogin extends StatefulWidget {
  @override
  _DriverloginState createState() => _DriverloginState();
}

class _DriverloginState extends State<Driverlogin> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _passwordVisible = false;
  bool isValid = true;
  bool _loggingIn = false; // Add a boolean variable to track login progress

  void checkField(TextEditingController controller) {
    setState(() {
      isValid = controller.text.isNotEmpty;
    });
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fields are empty")),
      );
    }
  }

  void login() async {
    checkField(idController);
    checkField(passwordController);

    if (isValid) {
      setState(() {
        _loggingIn = true; // Set login progress to true
      });

      try {
        // Query Firestore to check driver's credentials
        QuerySnapshot querySnapshot = await _firestore
            .collection("Drivers")
            .where("DriverId", isEqualTo: idController.text)
            .where("password", isEqualTo: passwordController.text)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // If credentials are valid, navigate to the next screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Drivernavmenu()),
          );
        } else {
          // Show error message if credentials are invalid
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid ID or password")),
          );
        }
      } catch (e) {
        // Handle any errors
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Failed")),
        );
      } finally {
        setState(() {
          _loggingIn = false; // Reset login progress when finished
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 500,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/busdriverloginpic.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 400.0),
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  color: Color.fromARGB(255, 40, 40, 40),
                ),
                width: double.infinity,
                height: 450,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          'Driver Login',
                          style: GoogleFonts.lexend(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Please sign in to continue.',
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.amber,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 25),
                      TextFormField(
                        controller: idController,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(100),
                        ],
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          hintText: "Driver's ID Number",
                          hintStyle: TextStyle(
                            color: Color.fromARGB(255, 121, 82, 0),
                          ),
                          filled: true,
                          fillColor: Color.fromARGB(218, 255, 255, 255),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0),
                            ),
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          prefixIcon: Icon(
                            Iconsax.card,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: passwordController,
                        obscureText: !_passwordVisible,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(50),
                        ],
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: const TextStyle(
                            color: Color.fromARGB(255, 121, 82, 0),
                          ),
                          filled: true,
                          fillColor: const Color.fromARGB(218, 255, 255, 255),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0),
                            ),
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          prefixIcon: const Icon(
                            Iconsax.lock,
                            color: Colors.brown,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            color: Colors.grey,
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return 'Password can\'t be empty';
                          }
                          if (text.length < 6) {
                            return "Please enter a valid password";
                          }
                          if (text.length > 49) {
                            return "Password can't be more than 50";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      const SizedBox(height: 40),
                      _loggingIn // Conditionally show the circular progress indicator
                          ? CircularProgressIndicator()
                          : GestureDetector(
                              onTap: login,
                              child: Container(
                                width: 250,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.black,
                                    elevation: 5,
                                  ),
                                  onPressed: login,
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Navigationmenu()),
                          );
                        },
                        child: Text(
                          'Login as user',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
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
