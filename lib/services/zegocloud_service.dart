import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:flutter/material.dart';

class ZegoServiceHelper {
  final String companionAcctId;
  final String companionName;
  final GlobalKey<NavigatorState> navigatorKey;

  ZegoServiceHelper({
    required this.companionAcctId,
    required this.companionName,
    required this.navigatorKey,
  });

  void initialize() {
    print(
        'Initializing Zego with UserID: $companionAcctId, UserName: $companionName');
    try {
      ZegoUIKitPrebuiltCallInvitationService().init(
        appID: 629459745,
        appSign:
            '105b0dd752f0765c307a053b512f3ff7e2ebff0d993f4433b803c0854832e596',
        userID: companionAcctId,
        userName: companionName,
        plugins: [ZegoUIKitSignalingPlugin()],
      );
      print('Zego initialized successfully');
    } catch (e) {
      print('Error during Zego initialization: $e');
    }
  }

  void deinitialize() {
    print('Deinitializing Zego');
    ZegoUIKitPrebuiltCallInvitationService().uninit();
    print('Zego deinitialized successfully');
  }
}
