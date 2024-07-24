import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Navbar extends StatefulWidget {
  final double iconGap;
  final double height;

  Navbar({this.iconGap = 0.0, this.height = 70.0});

  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem('lib/assets/icons/home.svg', 0),
          SizedBox(width: widget.iconGap),
          _buildNavItem('lib/assets/icons/patients.svg', 1),
          SizedBox(width: widget.iconGap),
          _buildNavItem('lib/assets/icons/notification.svg', 2),
          SizedBox(width: widget.iconGap),
          _buildNavItem('lib/assets/icons/menu.svg', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(String iconPath, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: SvgPicture.asset(
        iconPath,
        color: _selectedIndex == index ? Color(0xFF8048C8) : Colors.grey,
      ),
    );
  }
}
