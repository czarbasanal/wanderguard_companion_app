import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wanderguard_companion_app/models/patient.model.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:wanderguard_companion_app/utils/geopoint_converter.dart';
import 'package:wanderguard_companion_app/utils/size_config.dart';
import 'package:wanderguard_companion_app/widgets/dialogs/waiting_dialog.dart';

class PatientCardSmall extends StatelessWidget {
  final Patient patient;
  final Function() onLocate;
  final Function() onCall;
  final Function()? onTap;

  const PatientCardSmall({
    super.key,
    required this.patient,
    required this.onLocate,
    required this.onCall,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                  imageUrl: patient.photoUrl,
                  width: 85,
                  height: 85,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => WaitingDialog(
                      color: CustomColors.primaryColor, prompt: ''),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${patient.firstName} ${patient.lastName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      patient.contactNo,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Last Location:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FutureBuilder<String>(
                      future: GeoPointConverter.geoPointToAddress(
                          patient.lastLocTracked),
                      builder: (context, lastLocSnapshot) {
                        final location =
                            lastLocSnapshot.data ?? 'Fetching location...';
                        return Text(
                          location,
                          style: const TextStyle(fontSize: 14),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          minWidth: SizeConfig.screenWidth * 0.1,
                          height: SizeConfig.screenHeight * 0.048,
                          color: CustomColors.primaryColor,
                          onPressed: onLocate,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.placemark_fill,
                                color: CustomColors.secondaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Locate',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: CustomColors.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: CustomColors.primaryColor,
                            side: BorderSide(color: CustomColors.primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            minimumSize: Size(SizeConfig.screenWidth * 0.05,
                                SizeConfig.screenHeight * 0.048),
                          ),
                          onPressed: onCall,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.phone_fill,
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Call',
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
