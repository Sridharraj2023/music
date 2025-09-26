// import 'package:flutter/material.dart';
// import '../../Controller/Auth_Controller.dart';
// import '../../Model/user.dart';
// import '../Widgets/Custom_TextField.dart';
// import '../widgets/gradient_container.dart';
// import 'Login_Screen.dart';
// import 'SubscriptionTier_Screen.dart';

// class SignupScreen extends StatelessWidget {
//   final AuthController _authController = AuthController();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();

//   void _signUp(BuildContext context) {
//     final user = User(
//       username: _usernameController.text,
//       email: _emailController.text,
//       password: _passwordController.text,
//     );

//     _authController.signUp(user).then((_) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => SubscriptionTiersScreen()),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final double screenHeight = MediaQuery.of(context).size.height;

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         body: GradientContainer(
//           child: SafeArea(
//             child: Center(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       SizedBox(height: screenHeight * 0.05),

//                       // Logo & Header
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Image.asset(
//                             'assets/images/Elevate Logo White.png',
//                             height: screenWidth * 0.2,
//                             width: screenWidth * 0.2,
//                           ),
//                           Text(
//                             "ELEVATE",
//                             style: TextStyle(
//                               fontSize: screenWidth * 0.08,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                               letterSpacing: 1.5,
//                             ),
//                           ),
//                           Text(
//                             "by Frequency Tuning",
//                             style: TextStyle(
//                               fontSize: screenWidth * 0.03,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),

//                       SizedBox(height: screenHeight * 0.03),

//                       // Welcome Text
//                       Text(
//                         "Create your account to get started!",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: screenWidth * 0.045,
//                           fontWeight: FontWeight.w400,
//                           color: Colors.white,
//                         ),
//                       ),

//                       SizedBox(height: screenHeight * 0.04),

//                       // Username Input
//                       CustomTextField(hintText: "Username", controller: _usernameController),
//                       SizedBox(height: screenHeight * 0.02),

//                       // Email Input
//                       CustomTextField(hintText: "Email", controller: _emailController),
//                       SizedBox(height: screenHeight * 0.02),

//                       // Password Input
//                       CustomTextField(hintText: "Password", obscureText: true, controller: _passwordController),
//                       SizedBox(height: screenHeight * 0.02),

//                       // Confirm Password Input
//                       CustomTextField(hintText: "Confirm Password", obscureText: true, controller: _confirmPasswordController),
//                       SizedBox(height: screenHeight * 0.02),

//                       // Already have an account? Login Row
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             "Already have an account?",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: screenWidth * 0.035,
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.pushReplacement(
//                                 context,
//                                 MaterialPageRoute(builder: (context) => LoginScreen()),
//                               );
//                             },
//                             child: Text(
//                               "Login",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: screenWidth * 0.035,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),

//                       SizedBox(height: screenHeight * 0.02),

//                       // Signup Button
//                       ElevatedButton(
//                         onPressed: () => _signUp(context),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.black,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
//                           minimumSize: Size(screenWidth * 0.8, 50),
//                         ),
//                         child: Text(
//                           "Signup",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: screenWidth * 0.05,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),

//                       SizedBox(height: screenHeight * 0.02),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Controller/Auth_Controller.dart';
import '../../Model/user.dart';
import '../Widgets/Custom_TextField.dart';
import '../widgets/gradient_container.dart';
import 'Login_Screen.dart';
import 'SubscriptionTier_Screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthController _authController = AuthController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false; // To show a loading indicator

  void _signUp(BuildContext context) async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validate empty fields
    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("All fields are required."),
            backgroundColor: Colors.red),
      );
      return;
    }

    // Validate email format using a regex
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Please enter a valid email address."),
            backgroundColor: Colors.red),
      );
      return;
    }

    // Password match check
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Passwords do not match."),
            backgroundColor: Colors.red),
      );
      return;
    }

    // Password strength validation (min 8 characters, contains letters and numbers)
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    if (!passwordRegex.hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Password must be at least 8 characters and include both letters and numbers."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final user = User(username: username, email: email, password: password);
      final response = await _authController.signUp(user, context);

      // Handle signup result inside your controller as needed
    } catch (e) {
      log('Signup Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("An unexpected error occurred."),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GradientContainer(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    Image.asset('assets/images/Elevate Logo White.png',
                        height: screenWidth * 0.2, width: screenWidth * 0.2),
                    Text(
                      "ELEVATE",
                      style: TextStyle(
                          fontSize: screenWidth * 0.08,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5),
                    ),
                    Text(
                      "by Frequency Tuning",
                      style: TextStyle(
                          fontSize: screenWidth * 0.03,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Text("Create your account to get started!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: Colors.white)),
                    SizedBox(height: screenHeight * 0.04),
                    CustomTextField(
                        hintText: "Username", controller: _usernameController),
                    SizedBox(height: screenHeight * 0.02),
                    CustomTextField(
                        hintText: "Email", controller: _emailController),
                    SizedBox(height: screenHeight * 0.02),
                    CustomTextField(
                        hintText: "Password",
                        obscureText: true,
                        controller: _passwordController),
                    SizedBox(height: screenHeight * 0.02),
                    CustomTextField(
                        hintText: "Confirm Password",
                        obscureText: true,
                        controller: _confirmPasswordController),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account?",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.035)),
                        TextButton(
                          onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen())),
                          child: Text("Login",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.035)),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : ElevatedButton(
                            onPressed: () => _signUp(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.02),
                              minimumSize: Size(screenWidth * 0.8, 50),
                            ),
                            child: Text("Signup",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.bold)),
                          ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
