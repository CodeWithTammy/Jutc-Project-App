// Importing the OnboardingInfo class from onboardingmodel.dart
import 'package:jutcapp/component/onboardingmodel.dart';

// A class to hold data for onboarding screens
class OnboardingData {
  // List of OnboardingInfo objects
  List<OnboardingInfo> items = [
    // First onboarding screen information
    OnboardingInfo(
      title: 'Welcome to JUTC Bus Tracker!',
      description:
          'Discover the easiest way to find your next bus. Explore routes, check schedules, and get real-time updates right at your fingertips.',
      image: 'assets/onboardingbusstop.png',
    ),
    // Second onboarding screen information
    OnboardingInfo(
      title: 'Real-time notifications about your bus.',
      description:
          'Get instant updates on bus arrivals, delays, and changes. Never miss a bus again with our timely notifications.',
      image: 'assets/notification.png',
    ),
    // Third onboarding screen information
    OnboardingInfo(
      title: 'Top-Up Your Smarter Card',
      description:
          'Easily top-up your Smarter Card within the app. No more long lines – add funds instantly and keep your travel smooth and hassle-free.',
      image: 'assets/payment.png',
    )
  ];
}
