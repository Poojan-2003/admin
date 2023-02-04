

import 'package:admin/square_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class SendNoti extends StatefulWidget {
  const SendNoti({Key? key}) : super(key: key);

  @override
  State<SendNoti> createState() => _SendNotiState();
}

class _SendNotiState extends State<SendNoti> {
  TextEditingController username = TextEditingController();
  String? mtoken=" ";
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterlocalNotificationsPlugin;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermission();

    loadFCM();

    listenFCM();

    getToken();

    FirebaseMessaging.instance.subscribeToTopic("Animal");
  }
  void saveToken(String token) async{
    await FirebaseFirestore.instance.collection("userToken").doc("User1").set({
      'token':token,
    });
  }

  void getToken() async{
    await FirebaseMessaging.instance.getToken().then(
            (token){
          setState(() {
            mtoken = token;
          });

          saveToken(token!);
        });
  }

  void sendPushMessage(String token) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=AAAAXS30TEA:APA91bEUlhoYGRNen7r7-cpHOKONTrexbiC7I0zSONqbAroJn6x6RFGVg5-flntJi6vhR1_oHkSh2Eu2swyShT1LEouxSsIw7bdl6DJQjsNnlTcjrlKFSncH3fH6Da01kHP-TCwZtjlt',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': "Your PDF has been Printed Please Collect It",
              'title': "Grab your PDF"
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": token,
          },
        ),
      );
    } catch (e) {
      print("error push notification");
    }
  }

  void getTokenFromFirestore() async {

  }
  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterlocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }

  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );

      flutterlocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterlocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: username,
            ),
            GestureDetector(
              onTap: ()async{
                String name = username.text.trim();
                if(name != ""){
                  DocumentSnapshot snap = await FirebaseFirestore.instance.collection("users").doc(name).get();
                  String token = snap['token'];
                  print(token);
                  sendPushMessage(token);
                }
              },
              child: Container(
                height: 40,
                width: 200,
                color: Colors.red,
              ),
            )
          ],
        ),
      ),
    );
  }
}
