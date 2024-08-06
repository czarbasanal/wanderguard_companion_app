import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';

class BackupCompanionCustomBottomNavBar extends StatefulWidget {
  final double iconGap;
  final double height;
  final ValueChanged<int>? onTap;
  final int selectedIndex;

  BackupCompanionCustomBottomNavBar({
    this.iconGap = 0.0,
    this.height = 70.0,
    this.onTap,
    this.selectedIndex = 0,
  });

  @override
  _BackupCompanionCustomBottomNavBarState createState() =>
      _BackupCompanionCustomBottomNavBarState();
}

class _BackupCompanionCustomBottomNavBarState
    extends State<BackupCompanionCustomBottomNavBar> {
  void _onItemTapped(int index) {
    widget.onTap?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: CustomColors.tertiaryColor,
        // borderRadius: const BorderRadius.only(
        //   topLeft: Radius.circular(16.0),
        //   topRight: Radius.circular(16.0),
        // ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem('lib/assets/icons/home.svg', 0),
          SizedBox(width: widget.iconGap),
          _buildNavItem('lib/assets/icons/notification.svg', 1),
          SizedBox(width: widget.iconGap),
          _buildNavItem('lib/assets/icons/menu.svg', 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(String iconPath, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: SvgPicture.asset(
        iconPath,
        colorFilter: ColorFilter.mode(
          widget.selectedIndex == index
              ? CustomColors.primaryColor
              : Colors.grey,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
