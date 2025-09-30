// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'dart:developer';

import 'package:elevate/Controller/BottomBar_Controller.dart';
import 'package:elevate/Controller/Home_Controller.dart';
import 'package:elevate/Model/music_item.dart';
import 'package:elevate/View/Screens/Binaural_Screen.dart';
import 'package:elevate/View/Screens/Login_Screen.dart';
import 'package:elevate/View/Screens/Music_Screen.dart';
import 'package:elevate/View/Screens/SubscriptionTier_Screen.dart';
import 'package:elevate/View/Widgets/Gradient_Container.dart';
import 'package:elevate/View/Widgets/Music_List.dart';
import 'package:elevate/View/Widgets/Search_Bar.dart';
import 'package:elevate/View/Widgets/Tab_Bar.dart';
import 'package:elevate/View/Widgets/audio_player_widget.dart';
import 'package:elevate/View/Widgets/subscription_status.dart';
import 'package:elevate/View/Screens/Subscription_Details_Screen.dart';
import 'package:elevate/View/Screens/Notification_Preferences_Screen.dart';
import 'package:elevate/View/Screens/Notification_History_Screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey<ScaffoldState>();

  late TabController _tabController;
  final HomeController _homeController = HomeController();
  final BottomBarController bottomBarController =
      Get.find<BottomBarController>();
  late Future<List<MusicItem>> _musicItems;
  List<MusicItem>? _musicItems2;
  List<MusicItem>? _binauralItems2;
  late Future<List<MusicItem>> _binauralItems;
  bool isLoading = true;

  String? name;
  String? email;

  @override
  void initState() {
    super.initState();
    drawerData();

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    fetchMusic();
    _musicItems = _homeController.fetchMusic();

    _binauralItems = _homeController.fetchBinauralMusic();
  }

  void fetchMusic() async {
    // _musicItems = _homeController.fetchMusic();
    _musicItems2 = await _homeController.fetchMusic();

    // _binauralItems = _homeController.fetchBinauralMusic();
    _binauralItems2 = await _homeController.fetchBinauralMusic();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> drawerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    name = prefs.getString('name');
    email = prefs.getString('email');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: GradientContainer(
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      key: _drawerKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF6F41F3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$name",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                  Text(
                    "$email",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.subscriptions, color: Color(0xFF6F41F3)),
              title: Text("Subscription Details"),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionDetailsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: Color(0xFF6F41F3)),
              title: Text("Notification Preferences"),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationPreferencesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: Color(0xFF6F41F3)),
              title: Text("Notification History"),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationHistoryScreen(),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info, color: Colors.black),
              title: Text("About"),
              onTap: () {
                Navigator.pop(context); // Close drawer
                _showAboutDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context); // Close drawer
                _showLogoutConfirmation(context);
              },
            ),
          ],
        ),
      ),
      body: DefaultTabController(
        length: 3,
        child: GradientContainer(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // const Icon(Icons.grid_view_rounded,
                      //     color: Colors.white, size: 40),
                      IconButton(
                        onPressed: () {
                          _drawerKey.currentState?.openDrawer();
                        },
                        icon: const Icon(Icons.grid_view_rounded,
                            color: Colors.white, size: 40),
                      ),

                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "ELEVATE",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            "by Frequency Tuning",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SubscriptionTiersScreen()));
                        },
                        child: Image.asset(
                            'assets/images/Elevate Logo White.png',
                            height: 60,
                            width: 60),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Search Bar
                  const Text(
                    "What do you want to hear today?",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  SearchBar1(),
                  const SizedBox(height: 20),

                  // Tab Bar
                  CustomTabBar(tabController: _tabController),

                  // TabBarView
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildHomeTab(),
                        _buildNavigator(BinauralPage()),
                        _buildNavigator(MusicPage()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AudioPlayerWidget(
        musicList: _musicItems2!,
        binauralList: _binauralItems2!,
      ),
      // bottomNavigationBar: FutureBuilder<List<MusicItem>>(
      //   future: _musicItems,
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return SizedBox(); // Placeholder while loading
      //     } else if (snapshot.hasError || snapshot.data == null) {
      //       return SizedBox(); // Placeholder for error or empty data
      //     }
      //     return AudioPlayerWidget(
      //       musicList: snapshot.data!,
      //       binauralList: _binauralItems,
      //     );
      //   },
      // ), // Floating player persists
    );
  }

  Widget _buildNavigator(Widget child) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => child,
        );
      },
    );
  }

  // Home Tab Content
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            "Welcome! We're glad you're here.",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w400, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            "New Binaural for You",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          // MusicList(
          //     items: _homeController.getBinauralMusicItems(), isBinaural: true),
          const SizedBox(height: 20),
          // const Text(
          //   "Music for You",
          //   style: TextStyle(
          //       fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          // ),
          // const SizedBox(height: 5),
          // MusicList(items: _homeController.getMusicItems(), isBinaural: false),
          FutureBuilder<List<MusicItem>>(
            future: _binauralItems,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || snapshot.data!.isEmpty) {
                return Center(
                    child: Text("No music available",
                        style: TextStyle(color: Colors.white)));
              }

              return MusicList(items: snapshot.data!, isBinaural: true);
            },
          ),
          SizedBox(height: 20),
          const Text(
            "Music for You",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 10),
          FutureBuilder<List<MusicItem>>(
            future: _musicItems,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || snapshot.data!.isEmpty) {
                return Center(
                    child: Text("No music available",
                        style: TextStyle(color: Colors.white)));
              }

              return MusicList(items: snapshot.data!, isBinaural: false);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF6F41F3), // Background color
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(20), // Rounded corners for 3D effect
        ),
        title: const Text(
          "Confirm Logout",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // White text for contrast
            shadows: [
              Shadow(
                color: Colors.black45, // Shadow for 3D effect
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          "Are you sure you want to log out?",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70, // Light white for readability
            shadows: [
              Shadow(
                color: Colors.black38,
                blurRadius: 2,
                offset: Offset(1, 1),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly, // Space out buttons
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // White button
              foregroundColor: const Color(0xFF6F41F3), // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadowColor: Colors.black54, // 3D shadow effect
              elevation: 6, // Raised effect
            ),
            onPressed: () => Navigator.pop(context), // Close Dialog
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent, // Red button for logout
              foregroundColor: Colors.white, // White text
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadowColor: Colors.black54, // 3D shadow effect
              elevation: 6, // Raised effect
            ),
            onPressed: () {
              Navigator.pop(context); // Close Dialog
              _logout(context); // Call logout function
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); // Remove the token

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
      (route) => false,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF6F41F3), // Background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners
        ),
        title: const Text(
          "About",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white, // White text for contrast
            shadows: [
              Shadow(
                color: Colors.black45, // 3D Shadow
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          "This is an app description...",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70, // Light white for readability
            shadows: [
              Shadow(
                color: Colors.black38,
                blurRadius: 2,
                offset: Offset(1, 1),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center, // Center align buttons
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, // White button
              foregroundColor: const Color(0xFF6F41F3), // Text color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadowColor: Colors.black54, // 3D shadow effect
              elevation: 6, // Raised effect
            ),
            onPressed: () => Navigator.pop(context), // Close Dialog
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
