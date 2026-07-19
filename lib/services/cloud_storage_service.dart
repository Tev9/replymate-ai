import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CloudStorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _userId {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('User is not signed in.');
    }

    return user.uid;
  }

  String _safeDocumentId(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('/', '_')
        .replaceAll('\\', '_');
  }

  Future<void> saveDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection(collection)
        .doc(_safeDocumentId(documentId))
        .set(
      {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<Map<String, dynamic>?> loadDocument({
    required String collection,
    required String documentId,
  }) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection(collection)
        .doc(_safeDocumentId(documentId))
        .get();

    if (!snapshot.exists) {
      return null;
    }

    return snapshot.data();
  }
}