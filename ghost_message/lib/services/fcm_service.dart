import 'dart:convert';
import 'package:http/http.dart' as http;

class FcmService {

  static const String _serverKey =
      "PUT_YOUR_SERVER_KEY_HERE";

  static Future<void> sendPushNotification({
    required String token,
    required String title,
    required String body,
    String? postId,
  }) async {

    final url = Uri.parse("https://fcm.googleapis.com/fcm/send");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "key=$_serverKey",
      },
      body: jsonEncode({
        "to": token,
        "notification": {
          "title": title,
          "body": body,
        },
        "data": {
          "post_id": postId ?? "",
        }
      }),
    );

    print("FCM STATUS: ${response.statusCode}");
    print(response.body);
  }
}