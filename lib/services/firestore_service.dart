import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

class FirestoreService {
  static void initialize() {
    GetIt.instance.registerSingleton<FirestoreService>(FirestoreService());
  }

  static FirestoreService get instance => GetIt.instance<FirestoreService>();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addOrUpdateDocument(
      String collection, String docId, Map<String, dynamic> data) async {
    final docRef = _db.collection(collection).doc(docId);
    await docRef.set(data);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
      String collection, String docId) async {
    final docRef = _db.collection(collection).doc(docId);
    return await docRef.get();
  }

  Future<void> deleteDocument(String collection, String docId) async {
    final docRef = _db.collection(collection).doc(docId);
    await docRef.delete();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getDocumentStream(
      String collection, String docId) {
    return _db.collection(collection).doc(docId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCollectionStream(
      String collection) {
    return _db.collection(collection).snapshots();
  }
}
