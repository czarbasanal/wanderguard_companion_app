import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final int stepIndex;
  final int fieldIndex;
  final Widget Function(BuildContext context, Key key,
      Map<String, dynamic> field, bool isValid) builder;

  const CustomFormField({
    Key? key,
    required this.stepIndex,
    required this.fieldIndex,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return builder(context, key!, {}, true);
  }
}
