import 'dart:convert';

import 'package:europroyectos_app/Pages/ProjectsSteps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../Classes/Proyecto.dart';
import '../Classes/Usuario.dart';
import '../DAO/FirestoreDao.dart';
import 'ProyectosAdminList.dart';

List<Widget> _buildPersonWidgets(BuildContext context, List<dynamic> people) {
  return people.map((person) {
    String name = person['name'] ?? '';
    String surname = person['surname'] ?? '';
    String mail = person['email'] ?? '';
    String phone = person['phone'] ?? '';
    String dni = person['nif'] ?? '';

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('$name $surname'),
              content: SingleChildScrollView(
                  child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'DNI',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          dni,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Mail',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          mail,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Teléfono',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          phone,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
      child: Text(
        '$name $surname',
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }).toList();
}

class ProyectosAdminEdit extends StatefulWidget {
  final Proyecto proyecto;

  const ProyectosAdminEdit({Key? key, required this.proyecto})
      : super(key: key);

  @override
  _DetallesProyectoState createState() => _DetallesProyectoState();
}

class _DetallesProyectoState extends State<ProyectosAdminEdit> {
  final FirestoreDao fd = FirestoreDao();
  List<String> cities = [
    'Martos',
    'Málaga',
    'Granada',
    'Córdoba'
    // Agrega más ciudades según tus necesidades
  ];
  @override
  Widget build(BuildContext context) {
    List<String> opciones = ['aprobado', 'pendiente', 'rechazado'];
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Información',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProyectosAdminList(),
                    ));
              },
            ),
          ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 16),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.description, color: Colors.blue),
                    SizedBox(
                      width: 10,
                      height: 20,
                    ),
                    Flexible(
                      flex: 1,
                      child: Text(
                        'Número Ref: ${widget.proyecto.descripcion}.',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                        maxLines: null,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.blue),
                    SizedBox(width: 10),
                    Text(
                      'Fecha de inicio: ${DateFormat('dd/MM/yyyy').format(widget.proyecto.fechaInicio)}',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.blue),
                    SizedBox(width: 10),
                    Text(
                      'Fecha de fin: ${DateFormat('dd/MM/yyyy').format(widget.proyecto.fechaFin)}',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue),
                    SizedBox(width: 10),
                    Flexible(
                        flex: 1,
                        child: Text(
                          'Coordinador: ${widget.proyecto.coordinador}',
                          maxLines: null,
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        )),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_money, color: Colors.blue),
                    SizedBox(width: 10),
                    Text(
                      'Presupuesto: ${widget.proyecto.presupuesto}',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    PopupMenuButton<String>(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: Colors.blue),
                      ),
                      color: Colors.white,
                      itemBuilder: (BuildContext context) {
                        return opciones.map((String opcion) {
                          return PopupMenuItem<String>(
                            value: opcion,
                            child: Text(opcion),
                          );
                        }).toList();
                      },
                      onSelected: (String seleccion) {
                        setState(() {
                          widget.proyecto.estado = seleccion;
                          _actualizarUsuario(seleccion);
                        });
                      },
                      child: Row(
                        children: [
                          Icon(Icons.swap_calls, color: Colors.blue),
                          SizedBox(width: 10),
                          Text(
                            'Estado: ${widget.proyecto.estado}',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    PopupMenuButton<String>(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: Colors.blue),
                      ),
                      color: Colors.white,
                      itemBuilder: (BuildContext context) {
                        return cities.map((String opcion1) {
                          return PopupMenuItem<String>(
                            value: opcion1,
                            child: Text(opcion1),
                          );
                        }).toList();
                      },
                      onSelected: (String seleccion) {
                        setState(() {
                          widget.proyecto.ciudad = seleccion;
                          _actualizarCiudadUsuario(seleccion);
                        });
                      },
                      child: Row(
                        children: [
                          Icon(Icons.swap_calls, color: Colors.blue),
                          SizedBox(width: 10),
                          Text(
                            'Ciudad: ${widget.proyecto.ciudad}',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              ExpansionTile(
                title: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Alumnos',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                children: _buildPersonWidgets(context, widget.proyecto.alumnos),
              ),
              SizedBox(height: 16),
              ExpansionTile(
                title: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Profesores',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                children:
                    _buildPersonWidgets(context, widget.proyecto.profesores),
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                icon: Icon(CupertinoIcons.checkmark_rectangle),
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) =>
                          ProjectsSteps(proyecto: widget.proyecto)));
                },
                label: Text('Ver Requisitos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue, // Cambia el color de fondo del botón
                  foregroundColor:
                      Colors.white, // Cambia el color del texto del botón
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4, // Cambia la elevación del botón
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _actualizarUsuario(String seleccion) async {
    Usuario user = await fd.getUser(widget.proyecto.coordinador);
    for (var pr in user.proyectos) {
      if (pr.name == widget.proyecto.name) {
        pr.estado = seleccion;
      }
    }
    fd.addOrUpdateProjects(user.email, user.proyectos);
    sendPushNotification(
        user.token,
        'El proyecto ${widget.proyecto.name} ha cambiado',
        'El estado del proyecto ha cambiado a: $seleccion.');
  }

  void _actualizarCiudadUsuario(String seleccion) async {
    Usuario user = await fd.getUser(widget.proyecto.coordinador);
    for (var pr in user.proyectos) {
      if (pr.name == widget.proyecto.name) {
        pr.ciudad = seleccion;
      }
    }
    fd.addOrUpdateProjects(user.email, user.proyectos);
    sendPushNotification(
        user.token,
        'El proyecto ${widget.proyecto.name} ha cambiado',
        'La ciudad del proyecto ha cambiado a: $seleccion.');
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.lightBlue[100],
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2.0,
            spreadRadius: 1.0,
            offset: Offset(0.0, 1.0),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.title,
            color: Colors.black45,
            size: 32,
          ),
          const SizedBox(width: 16),
          Text(
            widget.proyecto.name,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
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
