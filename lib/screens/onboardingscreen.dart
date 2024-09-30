// Import statements
import 'package:flutter/material.dart'; // Flutter material design library
import 'package:jutcapp/component/onboardingdata.dart'; // Importing OnboardingData class
import 'package:jutcapp/screens/optionscreen.dart'; // Importing OptionScreen class

// OnboardingPage StatefulWidget class definition
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key}); // Constructor for OnboardingPage widget

  @override
  State<OnboardingPage> createState() => _OnboardingPageState(); // Creates state for OnboardingPage
}

// State class for managing stateful behavior of OnboardingPage
class _OnboardingPageState extends State<OnboardingPage> {
  final controller = OnboardingData(); // Instance of OnboardingData class to manage onboarding content
  final pageController = PageController(); // PageController instance for managing page view
  int currentIndex = 0; // Index to track current onboarding screen

  // Build method defining the UI for OnboardingPage
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Scaffold background color
      body: Column(
        children: [
          body(), // Renders the onboarding screen content
          buildDots(), // Renders the navigation dots indicating current screen
          button(), // Renders the continue or get started button
        ],
      ),
    );
  }

  // Method to build the main body of the onboarding screen
  Widget body() {
    return Expanded(
      child: Center(
        child: PageView.builder(
          onPageChanged: (value) {
            setState(() {
              currentIndex = value; // Updates currentIndex on page change
            });
          },
          itemCount: controller.items.length, // Total number of onboarding screens
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Displaying image associated with current onboarding screen
                  Image.asset(controller.items[currentIndex].image),

                  const SizedBox(height: 15), // Spacer for separation
                  // Displaying title of current onboarding screen
                  Text(
                    controller.items[currentIndex].title,
                    style: const TextStyle(fontSize: 25, color: Colors.amber, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),

                  // Displaying description of current onboarding screen
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Text(
                      controller.items[currentIndex].description,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Method to build the navigation dots indicating the current onboarding screen
  Widget buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controller.items.length,
        (index) => AnimatedContainer(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: currentIndex == index ? Colors.amber : Colors.grey, // Color based on current index
          ),
          height: 7,
          width: currentIndex == index ? 30 : 7, // Width based on current index
          duration: const Duration(milliseconds: 700), // Animation duration
        ),
      ),
    );
  }

  // Method to build the continue/get started button
  Widget button() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      width: MediaQuery.of(context).size.width * 0.9,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.black, // Button background color
      ),
      child: TextButton(
        onPressed: () {
          setState(() {
            if (currentIndex != controller.items.length - 1) {
              currentIndex++; // Move to the next onboarding screen
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Optionscreen()), // Navigate to Optionscreen
              );
            }
          });
        },
        child: Text(
          currentIndex == controller.items.length - 1 ? "Get started" : "Continue", // Button text based on current index
          style: const TextStyle(color: Colors.white), // Button text style
        ),
      ),
    );
  }
}
