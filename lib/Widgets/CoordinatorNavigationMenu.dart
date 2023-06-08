import 'package:europroyectos_app/DAO/FirestoreDao.dart';
import 'package:europroyectos_app/Pages/CoordinadorProjects.dart';
import 'package:europroyectos_app/Pages/CoordinadorProjectsAprobados.dart';
import 'package:europroyectos_app/Pages/CoordinadorProjectsRechazado.dart';
import 'package:europroyectos_app/pages/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Classes/Usuario.dart';
import 'package:flutter/material.dart';
import '../Pages/CoordinadorProjectsEspera.dart';
import '../pages/CoordinatorHomePage.dart';

class CoordinatorNavigationMenu extends StatelessWidget {
  const CoordinatorNavigationMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userDao = FirestoreDao();

    return Drawer(
      child: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              buildHeader(context, userDao),
              // buildMenuItems(context),
            ]),
      ),
    );
  }

  Widget buildHeader(BuildContext context, FirestoreDao userDao) {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<Usuario>(
      future: user != null ? userDao.getUser(user.email!) : null,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final usuarioActual = snapshot.data!;
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.lightBlue),
                child: Padding(
                  padding: const EdgeInsets.only(top: 50.0, left: 36),
                  child: InfoCard(
                      nombre: usuarioActual.name,
                      apellidos: usuarioActual.surname,
                      profesion: usuarioActual.email),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 0, top: 32, bottom: 16),
                child: Text(
                  "Navegar".toUpperCase(),
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              const Divider(color: Colors.black),
              Container(
                  padding: const EdgeInsets.only(top: 10, left: 24),
                  child: Wrap(
                    runSpacing: 16,
                    children: [
                      Stack(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.home_outlined),
                            title: const Text("Inicio",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.normal)),
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const CoordinatorHomePage()));
                            },
                          ),
                        ],
                      ),
                      ExpansionTile(
                        leading: const Icon(Icons.work_outline_sharp),
                        title: const Text("Proyectos",
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.normal)),
                        // onTap: () {
                        // Navigator.of(context).pushReplacement(
                        //     MaterialPageRoute(
                        //         builder: (context) =>
                        //             const ProyectosAdminList()));
                        // },
                        children: [
                          ListTile(
                            leading: const Icon(Icons.present_to_all),
                            title: const Text("Presentados",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.normal)),
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      CoordinadorProjects()));
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.check),
                            title: const Text("Aceptados",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.normal)),
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CoordinadorProjectsAprobados()));
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.more_time),
                            title: const Text("En espera",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.normal)),
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CoordinadorProjectsEspera()));
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.cancel_outlined),
                            title: const Text("Rechazados",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.normal)),
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CoordinadorProjectsRechazado()));
                            },
                          )
                        ],
                      ),
                    ],
                  )),
              Padding(
                padding: EdgeInsets.only(left: 0, top: 32, bottom: 16),
                child: Text(
                  "Perfil".toUpperCase(),
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
              const Divider(color: Colors.black),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: ListTile(
                  leading: const Icon(Icons.exit_to_app_outlined),
                  title: const Text("Salir",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.normal)),
                  onTap: () async {
                    actualizarTokenUsuario();
                    SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                    prefs.remove('username');
                    prefs.remove('password');
                    await FirebaseAuth.instance.signOut();

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LoginPage(
                                title: "Login",
                              )),
                      (route) => false,
                    );

                  },
                ),
              )
            ],
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
Future<void> actualizarTokenUsuario() async {
  final user = FirebaseAuth.instance.currentUser;
  var emailUser = user!.email;

  var fd=FirestoreDao();
  fd.actualizarTokenUser(user.email!, 'asd');

}

class InfoCard extends StatelessWidget {
  const InfoCard({
    Key? key,
    required this.nombre,
    required this.apellidos,
    required this.profesion,
  }) : super(key: key);

  final String nombre, apellidos, profesion;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.black,
        child: Icon(
          CupertinoIcons.person,
          color: Colors.white,
        ),
      ),
      title: Text("$nombre $apellidos",
          style: TextStyle(
              color: Colors.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal)),
      subtitle: Text(profesion,
          style: TextStyle(
              color: Colors.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w300)),
    );
  }
}
