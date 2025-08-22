// views/widgets/tab_bar.dart
import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  final TabController tabController;

  const CustomTabBar({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tabController.index == 4
            ? Colors.purple // Purple when selected
            : Colors.white, // White when unselected
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: tabController,
        tabs: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Tab(text: 'Home'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Tab(text: 'Binaural'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Tab(text: 'Music'),
          ),
        ],
        indicator: BoxDecoration(
          color: const Color(0xFF8A2BE2), // Bottom violet
          borderRadius: BorderRadius.circular(30),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.black,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(0),
      ),
    );
  }
}