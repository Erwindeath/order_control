import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:order_control/complements/colors.dart';

import 'package:order_control/firebase_options.dart';

import 'package:order_control/views/main_page.dart';
import 'package:upgrader/upgrader.dart';

/*Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final SecureStorage _storage = SecureStorage();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var prueba = await FirebaseMessaging.instance.getToken();
  print("Token: " + prueba.toString());
  await _storage.writeSecureData("token_firebase", prueba.toString());

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  var bigTextStyleInformation = BigTextStyleInformation(
    message.data['body'],
    htmlFormatBigText: true,
    htmlFormatContent: true,
  );

  var androidPlatformChannel = AndroidNotificationDetails(
    "ec.fsg.notifysound_bodega",
    "Farmacia San Gregorio Bodega",
    sound: const RawResourceAndroidNotificationSound('sangrego'),
    playSound: true,
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
    styleInformation: bigTextStyleInformation,
  );

  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannel);

  await flutterLocalNotificationsPlugin.show(
    message.notification.hashCode,
    message.data['title'],
    message.data['body'],
    platformChannelSpecifics,
    payload: '',
  );
}*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Upgrader.clearSavedSettings();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}

Colores colores = Colores();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const _localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const _supportedLocales = [
    Locale('es', ''), // Spanish, no country code
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: _localizationsDelegates,
      supportedLocales: _supportedLocales,
      title: 'OASIS',
      locale: const Locale('es'),
      theme: ThemeData(
        primarySwatch: Colores.esquemaColor,
      ),
      home: const MainPage(),
    );
  }
}
