import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ghost_message/app_scaffold_keys.dart';
import 'local_notification_service.dart';
import 'dart:io';
import 'dart:async';


class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal(); 
  factory NotificationService() => _instance;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _notificationSubscription;

  bool _hasSeededNotificationSnapshot = false;

  Future<void> initNotification(String uid) async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {

      if (Platform.isIOS) {
        await Future.delayed(const Duration(seconds: 1));
        String? apnsToken = await _fcm.getAPNSToken();
        if (apnsToken == null) {
          print("🚨 APNS Token ไม่มา! (ถ้าใช้ Simulator จะเป็นเรื่องปกติ ให้ลองใช้เครื่องจริง)");
          return; 
        }
      }

      String? token = await _fcm.getToken();
      if (token != null) {
        await _saveTokenToDatabase(uid, token);
        print("======== FCM TOKEN ========");
        print(token); 
        print("===========================");
      }

      _fcm.onTokenRefresh.listen((newToken) {
        _saveTokenToDatabase(uid, newToken);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title = message.notification?.title ?? "";
        final body = message.notification?.body ?? "";

        LocalNotificationService.show(
          title: title,
          body: body,
        );
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('User tapped on notification: ${message.notification?.title}');
      });

    } else {
      print("User declined or has not accepted permission");
    }
    await startInAppNotificationListener(uid);
  }

  Future<void> startInAppNotificationListener(String uid) async {
    await _notificationSubscription?.cancel();
    _hasSeededNotificationSnapshot = false;

    _notificationSubscription = _db
        .collection("users")
        .doc(uid)
        .collection("notifications")
        .orderBy("created_at", descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) async {
      if (!_hasSeededNotificationSnapshot) {
        _hasSeededNotificationSnapshot = true;
        return;
      }

      for (final change in snapshot.docChanges) {
        if (change.type != DocumentChangeType.added) {
          continue;
        }

        final data = change.doc.data();
        if (data == null) {
          continue;
        }

        final bool isPopupShown = data["is_popup_shown"] ?? false;
        if (isPopupShown) {
          continue;
        }

        final String title = data["title"] ?? "Notification";
        final String body = data["body"] ?? "";

        showInAppSnackBar(title: title, body: body);

        await change.doc.reference.update({
          "is_popup_shown": true,
        });
      }
    });
  }

  Future<void> stopInAppNotificationListener() async {
    await _notificationSubscription?.cancel();
    _notificationSubscription = null;
    _hasSeededNotificationSnapshot = false;
  }

  Future<void> createUserNotification({
    required String recipientUid,
    required String actorUid,
    required String actorName,
    required String type,
    required String title,
    required String body,
    String? postId,
  }) async {
    if (recipientUid == actorUid) {
      return;
    }

    final recipientDoc = await _db.collection("users").doc(recipientUid).get();
    if (!recipientDoc.exists) {
      return;
    }

    final recipientData = recipientDoc.data();
    final bool isNotificationEnabled =
        recipientData?["is_notification_enabled"] ?? true;

    if (!isNotificationEnabled) {
      return;
    }

    await _db
        .collection("users")
        .doc(recipientUid)
        .collection("notifications")
        .add({
      "type": type,
      "title": title,
      "body": body,
      "post_id": postId,
      "actor_uid": actorUid,
      "actor_name": actorName,
      "created_at": FieldValue.serverTimestamp(),
      "is_read": false,
      "is_popup_shown": false,
    });
  }

  void showInAppSnackBar({
    required String title,
    required String body,
  }) {
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) {
      return;
    }

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (body.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(body),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveTokenToDatabase(String uid, String token) async {
    await _db.collection("users").doc(uid).update({
      "fcm_token": token,
      }
    );
  }

  Future<void> saveFcmToken(String uid) async {

    final token = await FirebaseMessaging.instance.getToken();

    if (token == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({
      "fcm_token": token,
    });

    print("FCM TOKEN SAVED: $token");
  }
}