import 'package:flutter/material.dart';
import 'package:wanderguard_companion_app/screens/call_screen.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ZegoServiceHelper {
  final String companionAcctId;
  final String companionName;
  final GlobalKey<NavigatorState> navigatorKey;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ZegoServiceHelper({
    required this.companionAcctId,
    required this.companionName,
    required this.navigatorKey,
  });

  void initialize() {
    print(
        'Initializing Zego with UserID: $companionAcctId, UserName: $companionName');
    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: 629459745,
      appSign:
          '105b0dd752f0765c307a053b512f3ff7e2ebff0d993f4433b803c0854832e596',
      userID: companionAcctId,
      userName: companionName,
      plugins: [ZegoUIKitSignalingPlugin()],
    );

    _listenForCustomCalls();
  }

  void deinitialize() {
    print('Deinitializing Zego');
    ZegoUIKitPrebuiltCallInvitationService().uninit();
  }

  void _listenForCustomCalls() {
    _firestore
        .collection('custom_calls')
        .where('receiverId', isEqualTo: companionAcctId)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        if (doc['status'] == 'calling') {
          _acceptCustomCall(doc.id, doc['callerId'], doc['callerName']);
        }
      }
    });
  }

  void _acceptCustomCall(String callId, String callerId, String callerName) {
    _firestore.collection('custom_calls').doc(callId).update({
      'status': 'accepted',
    });

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => CallScreen(
          currentUserId: companionAcctId,
          userId: callerId,
          userName: callerName,
        ),
      ),
    );
  }
}
