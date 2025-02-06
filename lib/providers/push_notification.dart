import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:order_control/complements/storage/storage.dart';

import '../firebase_options.dart';

class PushNotification {
  static int _notificationId = 0;
  static String? prueba;
  final SecureStorage _storage = SecureStorage();
  static final StreamController<String> _messagecontroller =
      StreamController.broadcast();

  static Stream<String> get messagStream => _messagecontroller.stream;

  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static Future _background(RemoteMessage message) async {
    await Firebase.initializeApp();
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    var bigTextStyleInformation = BigTextStyleInformation(
      message.data['body'],
      htmlFormatBigText: true,
      htmlFormatContent: true,
    );
    var androidPlatformChannel = AndroidNotificationDetails(
        "ec.fsg.notifysound_bodega", "Farmacia San Gregorio Bodega",
        sound: const RawResourceAndroidNotificationSound('sangrego'),
        playSound: true,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: bigTextStyleInformation,
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'));
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannel);
    await flutterLocalNotificationsPlugin.show(
      _notificationId++,
      message.data['title'],
      message.data['body'],
      platformChannelSpecifics,
      payload: '',
    );
  }

  static Future _onMessage(RemoteMessage message) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    var bigTextStyleInformation = BigTextStyleInformation(
      message.data['body'],
      htmlFormatBigText: true,
      htmlFormatContent: true,
    );
    var androidPlatformChannel = AndroidNotificationDetails(
        "ec.fsg.notifysound_bodega", "Farmacia San Gregorio Bodega",
        sound: const RawResourceAndroidNotificationSound('sangrego'),
        playSound: true,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: bigTextStyleInformation,
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'));
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannel);
    await flutterLocalNotificationsPlugin.show(
      _notificationId++,
      // message.notification.hashCode,
      message.data['title'],
      message.data['body'],
      platformChannelSpecifics,
      payload: '',
    );

   // print("Message: ${message.data}");
    _messagecontroller.add(message.notification?.title ?? 'Sin datos');
  }

  static Future _onOpenAppMessage(RemoteMessage message) async {
   
    await Firebase.initializeApp();
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    var bigTextStyleInformation = BigTextStyleInformation(
      message.data['body'],
      htmlFormatBigText: true,
      htmlFormatContent: true,
    );
    var androidPlatformChannel = AndroidNotificationDetails(
        "ec.fsg.notifysound_bodega", "Farmacia San Gregorio Bodega",
        sound: const RawResourceAndroidNotificationSound('sangrego'),
        playSound: true,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: bigTextStyleInformation,
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'));
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannel);
    await flutterLocalNotificationsPlugin.show(
      _notificationId++,
      message.data['title'],
      message.data['body'],
      platformChannelSpecifics,
      payload: '',
    );
  }

  Future initializeApp() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).then((value) async {
     // print("Firebase initialized");
      prueba = await FirebaseMessaging.instance.getToken();
     // print("Token: " + prueba.toString());
      await _storage.writeSecureData("token_firebase", prueba.toString());
      
      //await FirebaseMessaging.instance.subscribeToTopic("all");

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true, // Required to display a heads up notification
        badge: true,
        sound: true,
      );
      FirebaseMessaging.onBackgroundMessage(_background);
      FirebaseMessaging.onMessage.listen(_onMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onOpenAppMessage);
    });
  }

  static closeStreams() {
    _messagecontroller.close();
  }

  //c398Po8rQgunhI11FjM-lK:APA91bHFu_8rmCGZpgNb5x75xJmyMiaH9RNgVY1mHjRJxbBQySLpMIN_u-85fPQHOy1JZZ7ufA9CwId-mw-gZ3O1XZlLAq_G9vjGHZpLI3EIuAJWzwxlUODGbz8gQdDzGLWKegLnZesI
}
