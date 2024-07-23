import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../routing/router.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

class ScreenWrapper extends StatefulWidget {
  final Widget? child;
  const ScreenWrapper({super.key, this.child});

  @override
  State<ScreenWrapper> createState() => _ScreenWrapperState();
}

class _ScreenWrapperState extends State<ScreenWrapper> {
  int index = 0;

  List<String> routes = [HomeScreen.route, ProfileScreen.route];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: widget.child ?? const Placeholder()),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        useLegacyColorScheme: false,
        backgroundColor: Colors.white,
        selectedFontSize: 13,
        unselectedFontSize: 13,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.grey.shade600,
        currentIndex: index,
        onTap: (i) {
          setState(() {
            index = i;

            GlobalRouter.I.router.go(routes[i]);
            // context.go(routes[i]);
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_rounded), label: "Profile"),
        ],
      ),
    );
  }
}
