import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SquareTile extends StatefulWidget {
  final String filename;
  final String ID;
  final String Type_of_xerox;
  final String Day;
  final String Month;
  final String Year;
  final String name;
  final Function()? onTap;
  
   SquareTile({
  super.key,
  required this.filename,
  required this.ID,
  required this.Day,
  required this.Month,
  required this.Type_of_xerox,
  required this.Year,
    required this.name,
    required this.onTap

  }) ;

  @override
  State<SquareTile> createState() => _SquareTileState();
}

class _SquareTileState extends State<SquareTile> {
 int sr = 1;

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

    // getToken();

    FirebaseMessaging.instance.subscribeToTopic("Animal");
  }

  // void saveToken(String token) async{
  //   await FirebaseFirestore.instance.collection("userToken").doc("User1").set({
  //     'token':token,
  //   });
  // }

  // void getToken() async{
  //   await FirebaseMessaging.instance.getToken().then(
  //           (token){
  //         setState(() {
  //           mtoken = token;
  //         });
  //
  //         saveToken(token!);
  //       });
  // }

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
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),

      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey[200]
      ),
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Column(
          children: [
            Row(
              children: [
                Text("Serial No : "),
                Text((sr++).toString()),

              ],
            ),
            SizedBox(height: 15,),
            Row(
              children: [
                Text("Name : "),
                Text(widget.name),
                SizedBox(width: 20,),
                Text("ID : "),
                Text(widget.ID),

              ],
            ),
            SizedBox(height: 15,),
            Row(
              children: [
                Text("Type Of Zerox : "),
                Text(widget.Type_of_xerox),

              ],
            ),
            SizedBox(height: 15,),
            Row(
              children: [
                Text("Date : "),
                Text(widget.Day),
                Text("-"),
                Text(widget.Month),
                Text("-"),
                Text(widget.Year),

              ],
            ),
            SizedBox(height: 15,),
            Row(
              children: [
                Text("FileName : "),
                Text(widget.filename),


              ],
            ),SizedBox(
              height: 15,
            ),
            // Row(
            //   children: [
            //     TextButton.icon(
            //       onPressed: widget.onTap,
            //       label: Text("Download PDF",style: TextStyle(fontSize: 20),),
            //       icon: Icon(Icons.download,size: 25,),
            //
            //
            //     )
            //   ],
            // ),
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(onTap: widget.onTap ,
            child: Icon(Icons.check_sharp,size: 35,)),
                SizedBox(width: 40,),
                Icon(Icons.clear,size: 35,)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
