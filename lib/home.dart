import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:notification/notification.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  NotificationServices notificationService = NotificationServices();
  @override
  void initState() {
    super.initState();
    notificationService.requestNotificationPermission();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    notificationService.isTokenRefersh();
    notificationService.getdeviceToken().then((value) {
      print("token is $value");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Firebase Notifcation"),
      ),
      body: Center(
        child: TextButton(
          onPressed: () {
            notificationService.getdeviceToken().then((value) async {
              var data = {
                'to': value.toString(),
                'priority': 'high',
                'notification': {
                  'title': 'Ghulam Mustafa',
                  'body': 'here is the body',
                },
                'data': {'type': 'msj', 'id': '1234'},
              };
              await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
                  body: jsonEncode(data),
                  headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                    'Authorization':
                        'AAAAIhW81lc:APA91bH1hKMYXcN--RUx-lrPCeXpmlYoTtcCjtPPAJp9b8L-PXTHDgVOAhmRhJ3BzBhuPwCOXh9VdeyqBRf3x9F9vwgC-n1tg40GskbetDEHLp24HPLhqwZb1l5h8qM39jRQ635Clpd6',
                  });
            });
          },
          child: const Text("Send Notification"),
        ),
      ),
    );
  }
}
