import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ghost_message/models/user_model.dart';
class UserFirestoreService {
  final FirebaseFirestore _instance = FirebaseFirestore.instance;

  CollectionReference? get _userData {
      return _instance.collection("users");
  }

  Stream<QuerySnapshot> getUsersStream() {
    if (_userData == null) {
      return Stream.empty();
    }
    final userDataStream = _userData!.orderBy("last_active", descending: false).orderBy("username", descending: false).snapshots();
    return userDataStream;
  }

  Stream<List<UserModel>> getUsers() {
    return getUsersStream().map((snapshots) {
      return snapshots.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['uid'] = doc.id;
        return UserModel.fromMap(doc.id, data);
      }).toList();
    });
  }

  Future<void> updateTheme(String uid, bool isDark) async {
    await _instance.collection("users").doc(uid).update({
      "is_dark_mode": isDark
    });
  }
  Future<void> updateLanguage(String uid, String language) async {
    await _instance.collection("users").doc(uid).update({
      "language": language,
    });
  }

  Future<void> reportUser(String uid, String reportedByUid) async {
    await _instance.collection("users").doc(uid).update({
      "report_count" : FieldValue.increment(1),
    });
  }

  Future<void> saveUserData(UserModel user) async {
    try {
      await _instance.collection("users").doc(user.uid).set(user.toMap());
    }
    catch(e) {
      rethrow;
    }
  }
  
  Future<void> setupInitialUser({
    required String uid, 
    required String username, 
    required String email, 
    String role = "user", 
    String photoPath = "", 
    String language = "eng", 
    int level = 1, 
    bool isDarkMode = false,
    int reportCount = 0,
    }) async {
    final newUser = UserModel(
      uid: uid,
      username: username,
      email: email,
      role: role,
      level: level,
      lastActive: DateTime.now(),
      createdAt: DateTime.now(),
      photoPath: photoPath,
      isDarkMode: isDarkMode,
      language: language,
      reportCount: reportCount,
    );
    await saveUserData(newUser);
  }

}