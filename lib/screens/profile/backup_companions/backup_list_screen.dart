import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wanderguard_companion_app/models/backup_companion.model.dart';
import 'package:wanderguard_companion_app/controllers/backup_companion_data_controller.dart';
import 'package:wanderguard_companion_app/controllers/companion_data_controller.dart';
import 'package:wanderguard_companion_app/screens/profile/backup_companions/select_patient.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
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
      backgroundColor: CustomColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: CustomColors.secondaryColor,
        surfaceTintColor: CustomColors.secondaryColor,
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
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: backupCompanions.length,
            itemBuilder: (context, index) {
              final backupCompanion = backupCompanions[index];

              return GestureDetector(
                onTap: () {
                  // Handle the onTap event if needed
                },
                child: Card(
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
                            width: 85,
                            height: 85,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => WaitingDialog(
                              color: CustomColors.primaryColor,
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
              );
            },
          );
        },
      ),
    );
  }
}
