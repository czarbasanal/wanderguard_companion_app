import 'package:flutter/material.dart';

class SectionItem {
  final String title;
  final String? leadingIcon;
  final Icon? trailingIcon;
  final VoidCallback? onTap;

  SectionItem({
    required this.title,
    this.leadingIcon,
    this.trailingIcon,
    this.onTap,
  });
}
