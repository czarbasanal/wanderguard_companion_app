import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallScreen extends StatelessWidget {
  final String currentUserId;
  final String userId;
  final String userName;

  CallScreen({
    required this.currentUserId,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call Screen'),
      ),
      body: Center(
        child: ZegoUIKitPrebuiltCall(
          appID: 629459745,
          appSign:
              '105b0dd752f0765c307a053b512f3ff7e2ebff0d993f4433b803c0854832e596',
          userID: currentUserId,
          userName: userName,
          callID: userId,
          config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
        ),
      ),
    );
  }
}
