import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';

void showImageSourceActionSheet(
    BuildContext context, Function(ImageSource) onImageSourceSelected) {
  showCupertinoModalPopup(
    context: context,
    builder: (_) => CupertinoActionSheet(
      title: const Text('Choose an image source'),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () {
            onImageSourceSelected(ImageSource.camera);
            Navigator.pop(context);
          },
          child: Text('Camera',
              style: TextStyle(color: CustomColors.primaryColor)),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            onImageSourceSelected(ImageSource.gallery);
            Navigator.pop(context);
          },
          child: Text('Gallery',
              style: TextStyle(color: CustomColors.primaryColor)),
        ),
      ],
      // cancelButton: CupertinoActionSheetAction(
      //   child: const Text('Cancel', style: TextStyle(color: Colors.red)),
      //   onPressed: () {
      //     Navigator.pop(context);
      //   },
      // ),
    ),
  );
}
