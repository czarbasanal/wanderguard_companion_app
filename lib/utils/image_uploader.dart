import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

Future<void> uploadImage(XFile pickedFile, String bucketName,
    Function(String) updateImageUrl) async {
  try {
    final ref = FirebaseStorage.instance
        .ref()
        .child(bucketName)
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(File(pickedFile.path));
    final url = await ref.getDownloadURL();
    updateImageUrl(url);
  } catch (error) {
    print('Error uploading image: $error');
  }
}
