import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
        print('Got a message whilst in the foreground!');
        if (message.notification != null) {
          print('Notification Title: ${message.notification!.title}');
          print('Notification Body: ${message.notification!.body}');
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('User tapped on notification: ${message.notification?.title}');
      });

    } else {
      print("User declined or has not accepted permission");
    }
  }

  

  Future<void> _saveTokenToDatabase(String uid, String token) async {
    await _db.collection("users").doc(uid).update({
      "fcm_token": token,
      }
    );
  }
}