import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wanderguard_companion_app/utils/image_uploader.dart';

import 'package:wanderguard_companion_app/widgets/dialogs/waiting_dialog.dart';

Future<void> pickImage(
    BuildContext context,
    ImagePicker picker,
    ImageSource source,
    String bucketName,
    Function(String) updateImageUrl) async {
  final pickedFile = await picker.pickImage(source: source);
  if (pickedFile != null) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WaitingDialog(
        prompt: 'Uploading...',
      ),
    );

    try {
      await uploadImage(pickedFile, bucketName, updateImageUrl);
    } finally {
      Navigator.pop(context); // Dismiss the waiting dialog
    }
  }
}
