// import 'package:flutter/material.dart';
// import '../../Controller/Auth_Controller.dart';
// import '../Widgets/Custom_TextField.dart';
// import '../Widgets/Gradient_Container.dart';
// import 'Signup_Screen.dart';

// class LoginScreen extends StatelessWidget {
//   final AuthController _authController = AuthController();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   void _login(BuildContext context) {
//     final email = _usernameController.text;
//     final password = _passwordController.text;

//     if (email.isEmpty || password.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text("Email and password cannot be empty"),
//             backgroundColor: Colors.red),
//       );
//       return;
//     }

//     _authController.login(email, password, context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final double screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       body: GradientContainer(
//         child: SafeArea(
//           child: Center(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     SizedBox(height: screenHeight * 0.05), // Dynamic Spacing

//                     // Header Row with Logo and Text
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Image.asset(
//                           'assets/images/Elevate Logo White.png',
//                           height: screenWidth * 0.2,
//                           width: screenWidth * 0.2,
//                         ),
//                         Text(
//                           "ELEVATE",
//                           style: TextStyle(
//                             fontSize: screenWidth * 0.08,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                             letterSpacing: 1.5,
//                           ),
//                         ),
//                         Text(
//                           "by Frequency Tuning",
//                           style: TextStyle(
//                             fontSize: screenWidth * 0.03,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),

//                     SizedBox(height: screenHeight * 0.04),

//                     // Welcome Message
//                     Text(
//                       "Welcome! We’re glad you’re here.",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.05,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                       ),
//                     ),

//                     SizedBox(height: screenHeight * 0.15),

//                     // Username Input
//                     CustomTextField(
//                       hintText: "Username",
//                       controller: _usernameController,
//                     ),
//                     SizedBox(height: screenHeight * 0.02),

//                     // Password Input
//                     CustomTextField(
//                       hintText: "Password",
//                       obscureText: true,
//                       controller: _passwordController,
//                     ),

//                     SizedBox(height: screenHeight * 0.02),

//                     // Forgot Password and Signup Row
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           "Forgot Password?",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: screenWidth * 0.035,
//                           ),
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => SignupScreen()),
//                             );
//                           },
//                           child: Text(
//                             "Signup",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: screenWidth * 0.035,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     SizedBox(height: screenHeight * 0.02),

//                     // Login Button
//                     ElevatedButton(
//                       onPressed: () => _login(context),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.black,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         padding: EdgeInsets.symmetric(
//                           vertical: screenHeight * 0.02,
//                         ),
//                         minimumSize: Size(screenWidth * 0.8, 50),
//                       ),
//                       child: Text(
//                         "Login",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: screenWidth * 0.05,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../Controller/Auth_Controller.dart';
import '../Widgets/Custom_TextField.dart';
import '../Widgets/Gradient_Container.dart';
import 'Signup_Screen.dart';

class LoginScreen extends StatelessWidget {
  final AuthController _authController = AuthController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validate empty fields
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Email and password cannot be empty."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate email format
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a valid email address."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _authController.login(email, password, context);
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

                    // Logo & Title
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/Elevate Logo White.png',
                          height: screenWidth * 0.2,
                          width: screenWidth * 0.2,
                        ),
                        Text(
                          "ELEVATE",
                          style: TextStyle(
                            fontSize: screenWidth * 0.08,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          "by Frequency Tuning",
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    Text(
                      "Welcome! We’re glad you’re here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.15),

                    // Email Field
                    CustomTextField(
                      hintText: "Email",
                      controller: _emailController,
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Password Field
                    CustomTextField(
                      hintText: "Password",
                      obscureText: true,
                      controller: _passwordController,
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignupScreen()),
                            );
                          },
                          child: Text(
                            "Signup",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Login Button
                    ElevatedButton(
                      onPressed: () => _login(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                        ),
                        minimumSize: Size(screenWidth * 0.8, 50),
                      ),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
