import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:wanderguard_companion_app/controllers/companion_data_controller.dart';
import 'package:wanderguard_companion_app/models/companion.model.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:wanderguard_companion_app/utils/size_config.dart';
import 'package:wanderguard_companion_app/widgets/dialogs/waiting_dialog.dart';
import '../../widgets/profile_content.dart';

class ProfileScreen extends StatefulWidget {
  static const route = '/profile';
  static const name = 'Profile';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = true;
  Companion? companion;
  TextEditingController? firstNameController;
  TextEditingController? lastNameController;
  TextEditingController? phoneNumberController;
  TextEditingController? emailController;
  TextEditingController? addressController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchCompanionData();
  }

  Future<void> fetchCompanionData() async {
    companion = CompanionDataController.instance.companionModelNotifier.value;
    if (companion != null) {
      firstNameController = TextEditingController(text: companion!.firstName);
      lastNameController = TextEditingController(text: companion!.lastName);
      phoneNumberController = TextEditingController(text: companion!.contactNo);
      emailController = TextEditingController(text: companion!.email);
      addressController = TextEditingController(text: companion!.address);
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      _uploadImage(pickedFile);
    }
  }

  Future<void> _uploadImage(XFile pickedFile) async {
    setState(() {
      isLoading = true;
    });

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('companion_photos')
          .child('${companion!.companionAcctId}.jpg');
      await ref.putFile(File(pickedFile.path));
      final url = await ref.getDownloadURL();

      // Update the companion's photoUrl in Firestore
      final updatedCompanion = companion!.copyWith(photoUrl: url);
      await CompanionDataController.instance.updateCompanion(updatedCompanion);

      setState(() {
        companion = updatedCompanion;
      });
    } catch (error) {
      print('Error uploading image: $error');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: CustomColors.tertiaryColor,
        body: Center(
          child: WaitingDialog(
            prompt: 'Loading...',
            color: CustomColors.primaryColor,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: CustomColors.tertiaryColor,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  color: CustomColors.primaryColor,
                  width: SizeConfig.screenWidth,
                  height: SizeConfig.screenHeight * 0.2,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 16,
                          ),
                          Text('Profile',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: CustomColors.secondaryColor))
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 100),
                ProfileContent(
                  companion: companion!,
                  firstNameController: firstNameController!,
                  lastNameController: lastNameController!,
                  phoneNumberController: phoneNumberController!,
                  emailController: emailController!,
                  addressController: addressController!,
                ),
              ],
            ),
            Positioned(
              top: SizeConfig.screenHeight * 0.11,
              left: SizeConfig.screenWidth * 0.32,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 5.0,
                  ),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: companion!.photoUrl,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 150,
                      height: 150,
                      color: CustomColors.primaryColor,
                      child: Center(
                        child: WaitingDialog(
                          color: CustomColors.primaryColor,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: CustomColors.tertiaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'lib/assets/images/profile-placeholder.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 200,
              right: 130,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: CustomColors.tertiaryColor, shape: BoxShape.circle),
                child: IconButton(
                  onPressed: () => _showImageSourceActionSheet(context),
                  icon: const Icon(
                    CupertinoIcons.photo_camera_solid,
                    size: 24,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Choose an image source'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              _pickImage(ImageSource.camera);
            },
            child: Text('Camera',
                style: TextStyle(color: CustomColors.primaryColor)),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              _pickImage(ImageSource.gallery);
            },
            child: Text('Gallery',
                style: TextStyle(color: CustomColors.primaryColor)),
          ),
        ],
      ),
    );
  }
}
