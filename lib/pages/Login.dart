import 'dart:convert';

import 'package:europroyectos_app/Classes/Usuario.dart';
import 'package:europroyectos_app/DAO/FirestoreDao.dart';
import 'package:europroyectos_app/Widgets/CustomTextField.dart';
import 'package:europroyectos_app/pages/CoordinatorHomePage.dart';
import 'package:europroyectos_app/pages/MainPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'AdminHomePage.dart';
import 'Password.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _passwordVisible = false;
  final TextEditingController _textUserController = TextEditingController();
  final TextEditingController _textPassController = TextEditingController();
  String _nombreUsuario = "Jeropis";
  final fd = FirestoreDao();
  bool userOk = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Esta función es llamada cuando el usuario pulsa el botón de retroceso de Android
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("¿Quieres salir de la aplicación?"),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Salir"),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: <Widget>[cuerpo()],
          ),
        ),
      ),
    );
  }

  Widget textoTitulo(String text) {
    return Text(
      text,
      style: const TextStyle(
          fontFamily: 'Poppins',
          color: Colors.blue,
          fontSize: 35,
          fontWeight: FontWeight.bold),
    );
  }

  Widget cuerpo() {
    return SingleChildScrollView(
        child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          const Padding(padding: EdgeInsets.all(40.0)),
          Center(
            child: SizedBox(
                width: double.infinity,
                height: 100,
                child: Image.network(
                    "http://europroyectos.eu/wp-content/uploads/europroyectos-logo-transparent.png")),
          ),
          const Padding(padding: EdgeInsets.all(20.0)),
          textoTitulo("Sign in"),
          CustomTextField("Usuario", _textUserController,
              Icon(CupertinoIcons.person_circle_fill)),
          campoPass(),
          const Padding(padding: EdgeInsets.all(5.0)),
          olvidadoContrasena(),
          const Padding(padding: EdgeInsets.all(5.0)),
          ElevatedButton.icon(
            onPressed: () async {
              if (_textPassController.text.trim().isEmpty) {
                Fluttertoast.showToast(
                  msg: "La contraseña está vacía",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 12.0,
                );
                return;
              }
              if (_textUserController.text.trim().isEmpty) {
                Fluttertoast.showToast(
                  msg: "El usuario está vacío",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 12.0,
                );
                return;
              }
              try {
                UserCredential userCredential = await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                        email: _textUserController.text.trim(),
                        password: _textPassController.text.trim());

                Usuario actual =
                    await fd.getUser(_textUserController.text.trim());

                actualizarTokenUsuario();

                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('username', _textUserController.text.trim());
                prefs.setString('password', _textPassController.text.trim());

                if (actual.isAdmin) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const AdminHomePage()));
                } else {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const CoordinatorHomePage()));
                }
              } on FirebaseAuthException catch (e) {
                if (e.code == 'user-not-found') {
                  Fluttertoast.showToast(
                    msg: "Usuario incorrecto",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 12.0,
                  );
                } else if (e.code == 'wrong-password') {
                  Fluttertoast.showToast(
                    msg: "Contraseña incorrecta",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 12.0,
                  );
                }
              } catch (e) {
                print(e);
              }
            },
            icon: Icon(CupertinoIcons.arrow_right_circle_fill),
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.lightBlue)),
            label: const Text(
              "Acceder",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
          ),
        ],
      ),
    ));
  }

  Future<void> actualizarTokenUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    var emailUser = user!.email;
    final fcmToken = await FirebaseMessaging.instance.getToken();
    fd.actualizarTokenUser(user.email!, fcmToken!);
  }

  TextButton olvidadoContrasena() {
    return TextButton(
        onPressed: () {
          showGeneralDialog(
            barrierDismissible: true,
            barrierLabel: "¿Ha olvidado su contraseña?",
            context: context,
            transitionDuration: Duration(milliseconds: 400),
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              Tween<Offset> tween;
              tween = Tween(begin: Offset(-1, 0), end: Offset.zero);
              return SlideTransition(
                position: tween.animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
                child: child,
              );
            },
            pageBuilder: (context, _, __) => Center(
              child: Container(
                height: 620,
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(40))),
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Column(
                    children: [
                      const Text(
                        "Póngase en contacto",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Para recuperar la contraseña, se tiene que poner en contacto con el director:",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const ListTile(
                        leading: Icon(Icons.person),
                        title: Text("Hector Bernal"),
                        subtitle: Text(
                          "Director y fundador",
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: const Text("+34 111111111"),
                        subtitle: const Text("Num. Teléfono",
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w300)),
                        trailing: IconButton(
                          onPressed: () {
                            Clipboard.setData(
                                const ClipboardData(text: '123456789'));
                          },
                          icon: const Icon(Icons.copy),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const ListTile(
                        leading: Icon(Icons.email),
                        title: Text(
                          "hector.bernal@europroyectos.eu",
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.normal,
                              fontSize: 14),
                        ),
                        subtitle: Text("Correo electrónico",
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w300)),
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: const Text("Calle Guatimozín, 2, 18010 Granada"),
                        subtitle: const Text("Dirección",
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w300)),
                        trailing: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.directions),
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(15)),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(CupertinoIcons.arrow_right),
                          label: Text("Aceptar"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
          // Navigator.of(context).pushReplacement(
          //     MaterialPageRoute(builder: (context) => const Password()));
        },
        child: const Text("¿Ha olvidado su contraseña?",
            style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                decorationColor: Colors.blue)));
  }

  Widget campoPass() {
    return Container(
        padding: const EdgeInsets.all(10),
        child: Form(
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.only(top: 8.0)),
              const Text(
                "Contraseña",
                style: TextStyle(color: Colors.black54),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 16.0)),
              TextFormField(
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(width: 2, color: Colors.lightBlue),
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                  prefixIcon: const Icon(Icons.password),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
                controller: _textPassController,
              ),
            ],
          ),
        ));
  }

  void sendPushNotification() async {
    const String serverToken =
        "AAAAeeZWz_c:APA91bHqUn3GxwbXuSHaRIFj_vOIBGlukOZloELPzMeFCgVN8vxpQZH4rowGxmtZ4GPtd9qWgAtFGcZfXc81wHThaZtV9-8mFVtMDxx4nTGptivQBPW2FQTgmOkVrR7RWDQLvP2L0NHG"; // Token de servidor de Firebase
    final String firebaseApiUrl = "https://fcm.googleapis.com/fcm/send";

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverToken',
    };

    final token =
        "dsu13ZmdQnyTzVfTTMnz10:APA91bF1qeDvwRjiDMJ9_quBTnEb9siDxggN6zQiG1-C1XqehhouS92KkjmKz-f7LmlvbKL2zXYMHZiGI7FW-cUspI0LTxeGKSjQwnkg-bWi8r4X5J4ogxeQDSfYzDC6HcsQT13nXvsp"; // Token del dispositivo al que deseas enviar la notificación
    final title = "¡Hola!";
    final body = "Esta es una notificación de prueba.";

    final bodyData = <String, dynamic>{
      'notification': {
        'title': title,
        'body': body,
      },
      'priority': 'high',
      'to': token,
    };

    try {
      final response = await http.post(
        Uri.parse(firebaseApiUrl),
        headers: headers,
        body: json.encode(bodyData),
      );
    } catch (e) {
      print('Error al enviar la notificación: $e');
    }
  }
}
