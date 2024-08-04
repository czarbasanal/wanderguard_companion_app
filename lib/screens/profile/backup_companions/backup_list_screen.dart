import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wanderguard_companion_app/models/backup_companion.model.dart';
import 'package:wanderguard_companion_app/controllers/backup_companion_data_controller.dart';
import 'package:wanderguard_companion_app/controllers/companion_data_controller.dart';
import 'package:wanderguard_companion_app/screens/profile/backup_companions/select_patient.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:wanderguard_companion_app/widgets/dialogs/confirmation_dialog.dart';
import 'package:wanderguard_companion_app/widgets/dialogs/waiting_dialog.dart';
import 'package:wanderguard_companion_app/routing/router.dart';
import 'package:google_fonts/google_fonts.dart';

class BackupCompanionListScreen extends StatefulWidget {
  const BackupCompanionListScreen({super.key});

  static const route = '/backup_companion';
  static const name = 'Backup Companions';

  @override
  _BackupCompanionListScreenState createState() =>
      _BackupCompanionListScreenState();
}

class _BackupCompanionListScreenState extends State<BackupCompanionListScreen> {
  @override
  Widget build(BuildContext context) {
    final companionAcctId = CompanionDataController
        .instance.companionModelNotifier.value?.companionAcctId;

    return Scaffold(
      backgroundColor: CustomColors.tertiaryColor,
      appBar: AppBar(
        backgroundColor: CustomColors.tertiaryColor,
        surfaceTintColor: CustomColors.tertiaryColor,
        title: Text('Backup Companions',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            size: 20,
          ),
          onPressed: () {
            GlobalRouter.I.router.pop();
          },
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_rounded,
              size: 30,
            ),
            onPressed: () {
              GlobalRouter.I.router.push(SelectPatientScreen.route);
            },
          ),
        ],
      ),
      body: StreamBuilder<List<BackupCompanion>>(
        stream: BackupCompanionDataController.instance
            .getBackupCompanionsByCompanionAcctId(companionAcctId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: WaitingDialog(
                prompt: 'Loading Backup Companions...',
                color: CustomColors.primaryColor,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final backupCompanions = snapshot.data;

          if (backupCompanions == null || backupCompanions.isEmpty) {
            return const Center(
                child: Text('No registered backup companions yet.'));
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: backupCompanions.length,
            itemBuilder: (context, index) {
              final backupCompanion = backupCompanions[index];

              return GestureDetector(
                onTap: () {
                  // Show detailed view
                },
                child: Stack(
                  children: [
                    Card(
                      color: CustomColors.secondaryColor,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: backupCompanion.photoUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => WaitingDialog(
                                  color: CustomColors.primaryColor,
                                  prompt: '',
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${backupCompanion.firstName} ${backupCompanion.lastName}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    backupCompanion.contactNo,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    'Address:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    backupCompanion.address,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 30,
                      right: 24,
                      child: GestureDetector(
                        onTap: () async {
                          bool confirm = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ConfirmationDialog(
                                title: 'Confirm Deletion',
                                content:
                                    'Are you sure you want to delete this backup companion?',
                                onConfirm: () async {
                                  await BackupCompanionDataController.instance
                                      .deleteBackupCompanion(backupCompanion
                                          .backupCompanionAcctId);
                                  Navigator.of(context).pop(true);
                                },
                                onCancel: () {
                                  Navigator.of(context).pop(false);
                                },
                              );
                            },
                          );
                          if (confirm) {
                            await BackupCompanionDataController.instance
                                .deleteBackupCompanion(
                                    backupCompanion.backupCompanionAcctId);
                          }
                        },
                        child: SvgPicture.asset(
                          'lib/assets/icons/delete-patient.svg',
                          width: 20,
                          height: 20,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    Positioned(
                        bottom: 20,
                        right: 10,
                        child: IconButton(
                          icon: Icon(
                            CupertinoIcons.phone_solid,
                            color: CustomColors.primaryColor,
                            size: 24,
                          ),
                          onPressed: () {
                            //handle call here
                          },
                        ))
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class Customcolors {}
