//Tamera Anderson - 133450406

// Import necessary packages and files
import 'package:animated_splash_screen/animated_splash_screen.dart'; // Animated splash screen package
import 'package:firebase_core/firebase_core.dart'; // Firebase core package
import 'package:flutter/foundation.dart'; // Flutter foundation package
import 'package:flutter/material.dart'; // Flutter material package
import 'package:get/get.dart'; // GetX state management package
import 'package:jutcapp/Utils/navigationmenu.dart'; // Custom navigation menu utility
import 'package:jutcapp/firebase_options.dart'; // Firebase options
import 'package:jutcapp/screens/onboardingscreen.dart'; // Onboarding screen

import 'Utils/colors.dart'; // Custom color definitions
import 'Utils/auth_controller.dart'; // Authentication controller

void main() async { 
  Get.put(AuthController()); // Initialize AuthController with GetX

  WidgetsFlutterBinding.ensureInitialized(); // Ensure widgets are initialized
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Initialize Firebase with default options
  runApp(const Home()); // Run the application with Home widget as the root
} 

// Home StatelessWidget that builds the application
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: darkblue, // Custom navigation bar background color
          indicatorColor: darkerblue, // Custom navigation bar indicator color
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.grey), // Custom label text style for navigation bar
          ),
        ),
        brightness: Brightness.dark, // Set brightness to dark
      ),
      darkTheme: ThemeData(brightness: Brightness.dark), // Dark theme
      themeMode: ThemeMode.light, // Set theme mode to light
      home: AnimatedSplashScreen(
        splash: 'assets/logo.png', // Splash screen image asset
        splashTransition: SplashTransition.fadeTransition, // Splash screen transition animation
        nextScreen: OnboardingPage(), // Next screen after splash screen
      ),
      debugShowCheckedModeBanner: false, // Disable debug banner
    );
  }
}

// Explanation: 
// Imports:

// animated_splash_screen: Used for creating an animated splash screen with transitions.
// firebase_core: Required for initializing Firebase services.
// flutter/foundation: Provides basic Flutter foundation classes and functions.
// flutter/material: Core Flutter material design widgets and utilities.
// get: A state management package.
// navigationmenu.dart: Custom utility for navigation menu.
// firebase_options.dart: File containing Firebase configuration options.
// onboardingscreen.dart: Screen displayed after the splash screen.
// colors.dart: Custom color definitions.
// auth_controller.dart: Controller for authentication logic.
// main() function:

// Get.put(AuthController()): Initializes AuthController using GetX state management.
// WidgetsFlutterBinding.ensureInitialized(): Ensures that Flutter widgets are initialized before proceeding.
// Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform): Asynchronously initializes Firebase with default platform options.
// runApp(const Home()): Starts the application with the Home widget as the root.
// Home StatelessWidget:

// MaterialApp: Configures the root widget for the Flutter application.
// theme: Sets the theme data for the application.
// navigationBarTheme: Customizes the navigation bar appearance.
// backgroundColor: Sets the background color of the navigation bar to darkblue.
// indicatorColor: Sets the color of the navigation bar indicator to darkerblue.
// labelTextStyle: Defines the text style for navigation bar labels with grey color.
// brightness: Sets the overall brightness of the theme to dark.
// darkTheme: Provides additional configurations for the dark theme.
// brightness: Ensures dark theme consistency.
// themeMode: Specifies that the theme should be in light mode.
// home: Defines the home screen of the application.
// AnimatedSplashScreen: Displays an animated splash screen.
// splash: Specifies the path to the splash screen image (assets/logo.png).
// splashTransition: Sets the transition animation for the splash screen (fade transition).
// nextScreen: Defines the screen to navigate to after the splash screen (OnboardingPage()).
// debugShowCheckedModeBanner: Disables the debug banner in release mode (false).
// This code initializes Firebase, sets up a themed Flutter application, and displays an animated splash screen before navigating to the OnboardingPage(). It uses various Flutter and external packages to manage state, handle navigation, and customize the user interface.