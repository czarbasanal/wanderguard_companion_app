import 'package:dynamic_multi_step_form/dynamic_multi_step_form.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';

class FormTextFieldConfig {
  static TextFieldConfiguration get textFieldConfiguration {
    OutlineInputBorder baseBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade400),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    );

    return TextFieldConfiguration(
      cursorColor: Colors.black87,
      fillColor: Colors.white,
      filled: true,
      textStyle: const TextStyle(color: Colors.black87),
      labelStyle: const TextStyle(color: Colors.black87),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: baseBorder,
      focusedBorder: baseBorder.copyWith(
        borderSide: BorderSide(color: CustomColors.primaryColor, width: 1),
      ),
      errorBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    );
  }

  static TelTextFieldConfiguration get telTextFieldConfiguration {
    OutlineInputBorder baseBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade400),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    );

    return TelTextFieldConfiguration(
      cursorColor: Colors.black87,
      fillColor: Colors.white,
      filled: true,
      textStyle: const TextStyle(color: Colors.black87),
      labelStyle: const TextStyle(color: Colors.black87),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: baseBorder,
      focusedBorder: baseBorder.copyWith(
        borderSide: BorderSide(color: CustomColors.primaryColor, width: 1),
      ),
      errorBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    );
  }
}
