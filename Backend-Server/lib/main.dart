// // ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, unnecessary_import

// import 'package:elevate/Controller/Subscription_Controller.dart';
// import 'package:elevate/View/Screens/SubscriptionTier_Screen.dart';
// import 'package:elevate/utlis/api_constants.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:get/get.dart';
// import 'Controller/BottomBar_Controller.dart';
// import 'View/Screens/Login_Screen.dart';
// import 'package:easy_splash_screen/easy_splash_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'View/Screens/Homepage_Screen.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   Get.put(BottomBarController()); // Inject GetX Controller
//   Stripe.publishableKey = ApiConstants.publishKey;

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: SplashScreen(), // Initial screen
//     );
//   }
// }

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     checkAuth(); // Check authentication on app start
//   }

//   Future<void> checkAuth() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('auth_token');

//     if (token != null && token.isNotEmpty) {
//       String? userEmail = prefs.getString('email');
//       final SubscriptionController _subscriptionController =
//           SubscriptionController();
//       final status =
//           await _subscriptionController.checkSubscriptionStatus(userEmail!);
//       if (status!['isActive'] == true) {
//         // User is authenticated and subscription is active
//         Get.off(() => const HomePage());
//       } else if (status['isActive'] == false) {
//         // User is authenticated but subscription is inactive
//         Get.off(() => SubscriptionTiersScreen());
//       } else {
//         // User is authenticated but subscription status is unknown
//         Get.off(() => SubscriptionTiersScreen());
//       }
//       // Get.off(() => const HomePage());
//     } else {
//       Get.off(() => LoginScreen());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return EasySplashScreen(
//       logo: Image.asset(
//         'assets/images/Elevate Logo White.png',
//         height: 150,
//         width: 150,
//       ),
//       title: const Text(
//         "ELEVATE",
//         style: TextStyle(
//           fontSize: 32,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//           letterSpacing: 1.5,
//         ),
//       ),
//       backgroundColor: const Color(0xFF6F41F3),
//       showLoader:
//           false, // Loader is not needed since we handle navigation manually
//     );
//   }
// }
//////////////////////////////////////////////////////////////////////////
//ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, unnecessary_import

import 'package:elevate/Controller/Subscription_Controller.dart';
import 'package:elevate/View/Screens/SubscriptionTier_Screen.dart';
import 'package:elevate/utlis/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'Controller/BottomBar_Controller.dart';
import 'View/Screens/Login_Screen.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'View/Screens/Homepage_Screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Debug: Print loaded environment variables
  ApiConstants.printEnvVars();
  print("Resolved API URL: ${ApiConstants.apiUrl}");
  print("Resolved Stripe Publishable Key: ${ApiConstants.publishKey}");
  
  // Use API URL from ApiConstants (reads from .env or uses default)
  print("Resolved API URL: ${ApiConstants.resolvedApiUrl}");

  // Inject GetX controller
  Get.put(BottomBarController());

  // Stripe publishable key
  Stripe.publishableKey = ApiConstants.publishKey;
  print("Stripe initialized with key: ${Stripe.publishableKey}");

  // Initialize notification service
  await NotificationService().initialize();
  print("Notification service initialized");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // Initial screen
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkAuth(); // Check auth on start
  }

  Future<void> checkAuth() async {
    await Future.delayed(
        const Duration(milliseconds: 300)); // Small delay for splash UI

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token != null && token.isNotEmpty) {
        String? userEmail = prefs.getString('email');
        final SubscriptionController _subscriptionController =
            SubscriptionController();

        final status =
            await _subscriptionController.checkSubscriptionStatus(userEmail!);

        if (status != null && status['isActive'] == true) {
          Get.off(() => const HomePage());
        } else {
          // If inactive or unknown
          Get.off(() => SubscriptionTiersScreen());
        }
      } else {
        Get.off(() => LoginScreen());
      }
    } catch (e) {
      debugPrint("Error during splash checkAuth: $e");
      Get.off(() => LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
      logo: Image.asset(
        'assets/images/Elevate Logo White.png',
        height: 150,
        width: 150,
      ),
      title: const Text(
        "ELEVATE",
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.5,
        ),
      ),
      backgroundColor: const Color(0xFF6F41F3),
      showLoader: false,
      loaderColor: Colors.white,
    );
  }
}
