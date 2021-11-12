import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/controllers.dart';
import '../main.dart';
import '../screens/screens.dart';

//in this class we are handling the foreground
//the background notification is handled by firebase messaging plugin
class HandleNotification {
  HandleNotification() {
    AwesomeNotifications().cancelAll();
  }
  static void initialize() async {
    //creating an instance from firebase messaging
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    //requesting the permission to send notifications
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    AwesomeNotifications().initialize(
      //setting the app icon
      'resource://drawable/app_launcher_icon',
      [
        //stablish the notification channel
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: Colors.white,
          ledColor: Colors.white,
          groupKey: "Attendance App",
        ),
      ],
    );
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // Insert here your friendly dialog box before call the request method
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    //listening to the foreground notifications
    FirebaseMessaging.onMessage.listen(
      (message) async {
        //extracting the notification data from the message
        RemoteNotification? notification = message.notification;
        //sending the notification
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            color: Colors.grey,
            id: notification.hashCode,
            channelKey: 'basic_channel',
            title: notification!.title,
            body: notification.body,
            notificationLayout: NotificationLayout.BigText,
            showWhen: true,
          ),
        );
        if (notification.body!.isCaseInsensitiveContains("New") &&
            notification.body!.isCaseInsensitiveContains("added")) {
          Get.find<ManagerHomeController>().incrementNotificationCount();
        } else {
          Get.find<HomeController>().incrementNotificationCount();
        }
      },
    );
    //listening when the user open the app opens from the notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final RemoteNotification? notification = message.notification;
      main();
      if (notification!.body!.isCaseInsensitiveContains("New") &&
          notification.body!.isCaseInsensitiveContains("added")) {
        Get.find<UserController>().reverseManagerMode();
      }
      navigator!.pushReplacementNamed(ManagerHomeScreen.route_name);
      Get.toNamed(NotificationScreen.route_name);
    });
  }
}
