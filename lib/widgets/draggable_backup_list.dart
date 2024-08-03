import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wanderguard_companion_app/controllers/backup_companion_data_controller.dart';
import 'package:wanderguard_companion_app/controllers/companion_data_controller.dart';
import 'package:wanderguard_companion_app/models/backup_companion.model.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:wanderguard_companion_app/widgets/dialogs/waiting_dialog.dart';

class DraggableBackupCompanionList extends StatefulWidget {
  const DraggableBackupCompanionList({super.key});

  @override
  _DraggableBackupCompanionListState createState() =>
      _DraggableBackupCompanionListState();
}

class _DraggableBackupCompanionListState
    extends State<DraggableBackupCompanionList> {
  late Future<List<BackupCompanion>> _backupCompanionsFuture;

  @override
  void initState() {
    super.initState();
    _backupCompanionsFuture = _loadBackupCompanions();
  }

  Future<List<BackupCompanion>> _loadBackupCompanions() async {
    String companionAcctId = CompanionDataController
        .instance.companionModelNotifier.value!.companionAcctId;
    return BackupCompanionDataController.instance
        .getBackupCompanionsByCompanionAcctId(companionAcctId)
        .first;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BackupCompanion>>(
      future: _backupCompanionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: CustomColors.primaryColor,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No backup companions found.'),
          );
        } else {
          final backupCompanions = snapshot.data!;
          return ListView.builder(
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
                                    prompt: ''),
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
                      bottom: 20,
                      right: 10,
                      child: IconButton(
                        icon: Icon(
                          CupertinoIcons.phone_solid,
                          color: CustomColors.primaryColor,
                          size: 24,
                        ),
                        onPressed: () {
                          // Handle call here
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
