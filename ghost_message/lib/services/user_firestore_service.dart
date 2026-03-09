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
    try {
      await _instance.collection("users").doc(uid).update({
        "is_dark_mode": isDark
      });
    }
    catch(e) {
      rethrow;
    }
  }
  Future<void> updateLanguage(String uid, String language) async {
    try {
      await _instance.collection("users").doc(uid).update({
      "language": language,
    });
    }
    catch (e) {
      rethrow;
    }
  }

  Future<void> reportUser(String uid, String reportedByUid) async {
    try {
      await _instance.collection("users").doc(uid).update({
        "report_count" : FieldValue.increment(1),
      });
    }
    catch (e) {
      rethrow;
    }
  }

  Future<void> saveUserData(UserModel user) async {
    try {
      await _instance.collection("users").doc(user.uid).set(user.toMap());
    }
    catch(e) {
      rethrow;
    }
  }

  Future<void> saveNewEmail(String email, String uid) async {
    try {
      await _instance.collection("users").doc(uid).update({
        "email" : email,
      });
    }
    catch(e) {
      rethrow;
    }
  }

  Future<void> saveNewUsername(String newUsername, String uid) async {
    try {
      await _instance.collection("users").doc(uid).update({
        "username" : newUsername,
      });
    }
    catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfilePicture(String uid, String downloadURL) async {
    try {
      await _instance.collection("users").doc(uid).update({
        "photo_path" : downloadURL,
      });
    }
    catch (e) {
      rethrow;
    }
  }

  Future<void> updateLastActive(String uid) async {
    try {
      await _instance.collection('users').doc(uid).update({
        'last_active': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error updating last active: $e");
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

    await setupInitialLeaderboard(
      uid: uid,
      username: username,
      photoPath: photoPath,
    );
  }

  Future<void> setupInitialLeaderboard({
    required String uid,
    required String username,
    required String photoPath,
  }) async {
    await _instance
        .collection('leaderboards')
        .doc('posts')
        .collection('entries')
        .doc(uid)
        .set({
      'uid': uid,
      'username': username,
      'photo_path': photoPath,
      'count': 0,
      'updated_at': FieldValue.serverTimestamp(),
    });

    await _instance
        .collection('leaderboards')
        .doc('likes')
        .collection('entries')
        .doc(uid)
        .set({
      'uid': uid,
      'username': username,
      'photo_path': photoPath,
      'count': 0,
      'updated_at': FieldValue.serverTimestamp( ),
    });
  }

  Future<void> rebuildLeaderboardFromPosts() async {
    final usersSnapshot = await _instance.collection('users').get();
    final postsSnapshot = await _instance.collection('posts').get();

    final Map<String, int> postCounts = {};
    final Map<String, int> likeCounts = {};

    for (final postDoc in postsSnapshot.docs) {
      final data = postDoc.data();
      final String authorId = data['author_id'] ?? '';
      final int likeCount = (data['like_count'] ?? 0) as int;

      if (authorId.isEmpty) continue;

      postCounts[authorId] = (postCounts[authorId] ?? 0) + 1;
      likeCounts[authorId] = (likeCounts[authorId] ?? 0) + likeCount;
    }

    for (final userDoc in usersSnapshot.docs) {
      final data = userDoc.data();
      final String uid = data['uid'] ?? userDoc.id;
      final String username = data['username'] ?? '';
      final String photoPath = data['photo_path'] ?? '';

      final int posts = postCounts[uid] ?? 0;
      final int likes = likeCounts[uid] ?? 0;

      await _instance
          .collection('leaderboards')
          .doc('posts')
          .collection('entries')
          .doc(uid)
          .set({
        'uid': uid,
        'username': username,
        'photo_path': photoPath,
        'count': posts,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _instance
          .collection('leaderboards')
          .doc('likes')
          .collection('entries')
          .doc(uid)
          .set({
        'uid': uid,
        'username': username,
        'photo_path': photoPath,
        'count': likes,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> updateUserPhotoEverywhere({
    required String uid,
    required String photoPath,
  }) async {
    await _instance.collection('users').doc(uid).update({
      'photo_path': photoPath,
    });

    await _instance
        .collection('leaderboards')
        .doc('posts')
        .collection('entries')
        .doc(uid)
        .update({
      'photo_path': photoPath,
    });

    await _instance
        .collection('leaderboards')
        .doc('likes')
        .collection('entries')
        .doc(uid)
        .update({
      'photo_path': photoPath,
    });
  }

}