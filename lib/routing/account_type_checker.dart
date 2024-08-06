import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> getCurrentUserAccountType() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    print('User is authenticated: ${user.uid}');
    try {
      final List<String> homeCollections = [
        'backup_companions',
        'companions',
        'patients'
      ];

      for (var collectionName in homeCollections) {
        final userDoc = await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null && data.containsKey('acctType')) {
            print('User document data: $data');
            print('Account type: ${data['acctType']}');
            return data['acctType'];
          } else {
            print(
                'User document in collection $collectionName does not contain acctType');
          }
        } else {
          print('User document does not exist in collection $collectionName');
        }
      }
    } catch (e) {
      print('Error fetching user document: $e');
    }
  } else {
    print('No authenticated user found');
  }
  return null;
}
