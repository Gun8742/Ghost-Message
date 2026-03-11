const {setGlobalOptions} = require("firebase-functions/v2");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

setGlobalOptions({maxInstances: 10});

exports.sendNotification = onDocumentCreated(
  "users/{uid}/notifications/{notificationId}",
  async (event) => {

    const notification = event.data.data();
    const uid = event.params.uid;

    const userDoc = await admin.firestore()
      .collection("users")
      .doc(uid)
      .get();

    const fcmToken = userDoc.data()?.fcm_token;

    if (!fcmToken) {
      console.log("No FCM token");
      return;
    }

    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
      },
      token: fcmToken,
    };

    await admin.messaging().send(message);

    console.log("Notification sent");
  }
);