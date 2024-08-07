import 'package:flutter/material.dart';
import 'package:wanderguard_companion_app/utils/colors.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

enum CallType { voiceCall, videoCall }

class CallPatientButton extends StatelessWidget {
  final String patientAcctId;
  final String patientName;
  final CallType callType;
  final double opacity;

  const CallPatientButton({
    super.key,
    required this.patientAcctId,
    required this.patientName,
    this.callType = CallType.voiceCall,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: ZegoSendCallInvitationButton(
        isVideoCall: callType == CallType.videoCall,
        invitees: [
          ZegoUIKitUser(id: patientAcctId, name: patientName),
        ],
        resourceID: 'wanderguard',
        iconSize: const Size(50, 50), // Default icon size
        buttonSize: const Size(50, 50), // Default button size
        onPressed:
            (String inviterID, String inviterName, List<String> invitees) {
          debugPrint('SendCallButton pressed for patient: $patientAcctId');
        },
      ),
    );
  }
}
