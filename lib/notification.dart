import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notification/message_screen.dart';

class NotificationServices {
  //firebase messging instace
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  //instance
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // take permission from user
  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User Granted permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("User Granted provisonal permission");
    } else {
      AppSettings.openAppSettings();
      print("user delined permission");
    }
  }

  //inital local notification
  void initLocalNotifcation(BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSetting = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveBackgroundNotificationResponse: (payload) {
      handleMessage(context, message);
    });
  }

  // when message come we will show it
  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
        //payload
        print(message.data['type']);
        print(message.data['id']);
      }
      //when we click notifcation it redirect the screen
      if (Platform.isAndroid) {
        initLocalNotifcation(context, message);
        showNotification(message);
      } else {
        showNotification(message);
      }
    });
  }

  // show notification
  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(1000).toString(),
      'high importance notification',
      importance: Importance.max,
    );

    // set android notiification detaiils
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: 'Your chaneel Description',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    // firebase dont use it for ios
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );

    //notifcation Details
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.title.toString(),
          notificationDetails);
    });
  }

  // get device token
  Future<String?> getdeviceToken() async {
    String? token = await messaging.getToken();
    return token;
  }

  // refersh the  device token
  void isTokenRefersh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      print("refersh");
    });
  }

  // for android handle message
  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'msj') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MessageScreen(
                    id: message.data['id'],
                  )));
    }
  }

  //when app in background
  Future<void> setupInteractMessage(BuildContext context) async {
    // when app is kill
    RemoteMessage? initalMessgae =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initalMessgae != null) {
      handleMessage(context, initalMessgae);
    }
    // when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }
}
