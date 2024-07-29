import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'section_item.dart';

class Section extends StatelessWidget {
  final String title;
  final List<SectionItem> items;

  Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF313131),
          ),
        ),
        const SizedBox(height: 10),
        ...items.map((item) => ListTile(
              leading: item.leadingIcon != null
                  ? SvgPicture.asset(
                      item.leadingIcon!,
                      width: 24,
                      height: 24,
                      color: const Color(0xFF313131),
                    )
                  : null,
              title: Text(
                item.title,
                style: const TextStyle(color: Color(0xFF313131)),
              ),
              trailing: item.trailingIcon,
              onTap: item.onTap,
            )),
      ],
    );
  }
}
