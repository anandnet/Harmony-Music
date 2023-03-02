import 'package:flutter/material.dart';

class PlayListScreen extends StatelessWidget {
  const PlayListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: 0, //_selectedIndex,
            minWidth: 60,
            leading: const SizedBox(height: 100),
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.green,
            destinations: <NavigationRailDestination>[
              railDestination("Songs"),
            ],
            // selectedIconTheme: IconThemeData(color: Colors.white),
            unselectedIconTheme: const IconThemeData(color: Colors.black),
            selectedLabelTextStyle: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white38),
          ),
          const VerticalDivider(thickness: 1, width: 2),
          Expanded(child: Container())
        ],
      ),
    );
  }
  NavigationRailDestination railDestination(String label) {
    return NavigationRailDestination(
      icon: const SizedBox.shrink(),
      label: RotatedBox(quarterTurns: -1, child: Text(label)),
    );
  }
}