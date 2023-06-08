import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'Login.dart';

class Password extends StatelessWidget {
  const Password({Key? key}) : super(key: key);

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
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const LoginPage(
                    title: 'Europroyectos',
                  ),
                ));
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Póngase en contacto con el director de Europroyectos",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Para recuperar la contraseña, se tiene que poner en contacto con el director:",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const ListTile(
                    leading: Icon(Icons.person),
                    title: Text("Hector Bernal"),
                    subtitle: Text("Director y fundador"),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text("+34 111111111"),
                    subtitle: const Text("Num. Teléfono"),
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
                    title: Text("hector.bernal@europroyectos.eu"),
                    subtitle: Text("Correo electrónico"),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text("Calle Guatimozín, 2, 18010 Granada"),
                    subtitle: const Text("Dirección"),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.directions),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
