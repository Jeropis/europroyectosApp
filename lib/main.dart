import 'package:europroyectos_app/DAO/FirestoreDao.dart';
import 'package:europroyectos_app/firebase_options.dart';
import 'package:europroyectos_app/pages/AdminHomePage.dart';
import 'package:europroyectos_app/pages/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Classes/Usuario.dart';
import 'Pages/CoordinatorHomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print('FCM Token: $fcmToken');
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  String? password = prefs.getString('password');

  print(username);
  print(password);

  Widget appWidget;

  if (username != null && password != null) {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: username, password: password);
      FirestoreDao fd = FirestoreDao();
      Usuario actual = await fd.getUser(username);

      if (actual.isAdmin) {
        appWidget = AdminHomePage();
      } else {
        appWidget = CoordinatorHomePage();
      }
    } catch (e) {
      appWidget = LoginPage(title: 'europroyectos');
    }
  } else {
    appWidget = LoginPage(title: 'europroyectos');
  }

  runApp(MyApp(appWidget: appWidget));
}

class MyApp extends StatelessWidget {
  final Widget appWidget;
  MyApp({Key? key, required this.appWidget}) : super(key: key);

  // FirebaseMessaging instance
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Configure notification handling
  void configureMessaging() {
    _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.notification?.title}');
      // Maneja la notificación recibida en la aplicación en primer plano
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Opened message: ${message.notification?.title}');
      // Maneja la notificación cuando se abre la aplicación desde una notificación
    });
  }

  // Maneja las notificaciones en segundo plano
  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print('Background message: ${message.notification?.title}');
    // Maneja la notificación recibida en la aplicación en segundo plano
  }

  @override
  Widget build(BuildContext context) {
    configureMessaging();

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: appWidget,
    );
  }
}
