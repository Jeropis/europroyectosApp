import 'dart:ffi';

import 'package:europroyectos_app/Classes/Proyecto.dart';
import 'package:europroyectos_app/DAO/FirestoreDao.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Classes/Alumno.dart';
import '../Classes/Profesor.dart';
import '../Classes/Usuario.dart';
import '../Widgets/CoordinatorNavigationMenu.dart';
import 'CoordinatorHomePage.dart';

class ProjectsSteps extends StatefulWidget {
  final Proyecto proyecto;
  const ProjectsSteps({super.key, required this.proyecto});

  @override
  State<ProjectsSteps> createState() => NewProjectsStepsPageState();
}

class NewProjectsStepsPageState extends State<ProjectsSteps> {
  FirestoreDao fb = FirestoreDao();
  late Future<List<Usuario>> listaUsuarios;

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.red;
  }

  @override
  void initState() {
    super.initState();
    listaUsuarios = fb.getUsers();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text("Pasos a Seguir"),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
              onPressed: () async {
                _actualizarEstado();
                List<Usuario> listaUsuariosA = await listaUsuarios;
                for (var u in listaUsuariosA) {
                  if (u.email == widget.proyecto.coordinador) {
                    sendPushNotification(
                        u.token,
                        'La lista de pasos ha sido actualizada',
                        'La lista de pasos de tu proyecto ${widget.proyecto.name} ha sido modificada.');
                  }
                }
              },
              icon: Icon(Icons.save))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue[100]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              margin: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Acuerdo de movilidad',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )),
                  Checkbox(
                    checkColor: Colors.white,
                    fillColor: MaterialStateProperty.resolveWith(getColor),
                    value: widget.proyecto.pasosASeguir['acuerdoMovilidad'],
                    onChanged: (bool? value) {
                      setState(() {
                        widget.proyecto.pasosASeguir['acuerdoMovilidad'] =
                            value!;
                      });
                    },
                  )
                ],
              ),
            ),
            Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue[100]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                margin: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Primer pago (80%)',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    Checkbox(
                      checkColor: Colors.white,
                      fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: widget.proyecto.pasosASeguir['primerPago'],
                      onChanged: (bool? value) {
                        setState(() {
                          widget.proyecto.pasosASeguir['primerPago'] = value!;
                        });
                      },
                    )
                  ],
                )),
            Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue[100]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                margin: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Lista de participantes',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    Checkbox(
                      checkColor: Colors.white,
                      fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: widget.proyecto.pasosASeguir['participantes'],
                      onChanged: (bool? value) {
                        setState(() {
                          widget.proyecto.pasosASeguir['participantes'] =
                              value!;
                        });
                      },
                    )
                  ],
                )),
            Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue[100]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                margin: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Copias DNI',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    Checkbox(
                      checkColor: Colors.white,
                      fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: widget.proyecto.pasosASeguir['copiasDni'],
                      onChanged: (bool? value) {
                        setState(() {
                          widget.proyecto.pasosASeguir['copiasDni'] = value!;
                        });
                      },
                    )
                  ],
                )),
            Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue[100]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                margin: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('CV\'s participantes',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    Checkbox(
                      checkColor: Colors.white,
                      fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: widget.proyecto.pasosASeguir['curriculums'],
                      onChanged: (bool? value) {
                        setState(() {
                          widget.proyecto.pasosASeguir['curriculums'] = value!;
                        });
                      },
                    )
                  ],
                )),
            Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue[100]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                margin: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Detalles de los vuelos',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    Checkbox(
                      checkColor: Colors.white,
                      fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: widget.proyecto.pasosASeguir['vuelos'],
                      onChanged: (bool? value) {
                        setState(() {
                          widget.proyecto.pasosASeguir['vuelos'] = value!;
                        });
                      },
                    )
                  ],
                )),
            Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue[100]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                margin: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Segundo pago (20%)',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    Checkbox(
                      checkColor: Colors.white,
                      fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: widget.proyecto.pasosASeguir['segundoPago'],
                      onChanged: (bool? value) {
                        setState(() {
                          widget.proyecto.pasosASeguir['segundoPago'] = value!;
                        });
                      },
                    )
                  ],
                )),
            Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue[100]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                margin: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Acuerdo de practicas',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    Checkbox(
                      checkColor: Colors.white,
                      fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: widget.proyecto.pasosASeguir['acuerdoPracticas'],
                      onChanged: (bool? value) {
                        setState(() {
                          widget.proyecto.pasosASeguir['acuerdoPracticas'] =
                              value!;
                        });
                      },
                    )
                  ],
                )),
            Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue[100]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                margin: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Copia seguro médico',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    Checkbox(
                      checkColor: Colors.white,
                      fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: widget.proyecto.pasosASeguir['copiaSeguro'],
                      onChanged: (bool? value) {
                        setState(() {
                          widget.proyecto.pasosASeguir['copiaSeguro'] = value!;
                        });
                      },
                    )
                  ],
                )),
            Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue[100]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                margin: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Habitaciones',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    Checkbox(
                      checkColor: Colors.white,
                      fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: widget.proyecto.pasosASeguir['habitaciones'],
                      onChanged: (bool? value) {
                        setState(() {
                          widget.proyecto.pasosASeguir['habitaciones'] = value!;
                        });
                      },
                    )
                  ],
                )),
            Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue[100]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                margin:
                    EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Plan de divulgación',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    Checkbox(
                      checkColor: Colors.white,
                      fillColor: MaterialStateProperty.resolveWith(getColor),
                      value: widget.proyecto.pasosASeguir['disseminationPlan'],
                      onChanged: (bool? value) {
                        setState(() {
                          widget.proyecto.pasosASeguir['disseminationPlan'] =
                              value!;
                        });
                      },
                    )
                  ],
                )),
          ],
        ),
      ));
  void _actualizarEstado() async {
    Usuario user = await fb.getUser(widget.proyecto.coordinador);
    int index =
        user.proyectos.indexWhere((pr) => pr.name == widget.proyecto.name);
    if (index != -1) {
      setState(() {
        user.proyectos[index] = widget.proyecto;
      });
      fb.addOrUpdateProjects(user.email, user.proyectos);
    }
  }

  void sendPushNotification(String token, String title, String body) async {
    const String serverToken =
        "AAAAeeZWz_c:APA91bHqUn3GxwbXuSHaRIFj_vOIBGlukOZloELPzMeFCgVN8vxpQZH4rowGxmtZ4GPtd9qWgAtFGcZfXc81wHThaZtV9-8mFVtMDxx4nTGptivQBPW2FQTgmOkVrR7RWDQLvP2L0NHG"; // Token de servidor de Firebase
    final String firebaseApiUrl = "https://fcm.googleapis.com/fcm/send";

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverToken',
    };

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
