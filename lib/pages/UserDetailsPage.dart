import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:europroyectos_app/Classes/Proyecto.dart';
import 'package:europroyectos_app/DAO/FirestoreDao.dart';
import 'package:europroyectos_app/Widgets/CustomTextField.dart';
import 'package:europroyectos_app/pages/CoordinadoresAdmin.dart';
import 'package:flutter/foundation.dart';
import 'package:europroyectos_app/Classes/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ProyectosAdminEdit.dart';

class UserDetailsPage extends StatefulWidget {
  final Usuario user;
  const UserDetailsPage({Key? key, required this.user}) : super(key: key);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _emailController;
  late TextEditingController _countryController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  late bool _isAdmin;
  late List<Proyecto> _proyectos;
  late Proyecto _selectedProyecto;
  final FirestoreDao fd = FirestoreDao();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _surnameController = TextEditingController(text: widget.user.surname);
    _emailController = TextEditingController(text: widget.user.email);
    _countryController = TextEditingController(text: widget.user.country);
    _passwordController = TextEditingController(text: widget.user.password);
    _phoneController = TextEditingController(text: widget.user.phone);
    _isAdmin = widget.user.isAdmin;
    _proyectos = widget.user.proyectos;
    _selectedProyecto = _proyectos.isNotEmpty
        ? _proyectos[0]
        : Proyecto(
            id: '',
            name: '',
            descripcion: '',
            fechaInicio: DateTime.now(),
            fechaFin: DateTime.now(),
            coordinador: '',
            presupuesto: 0,
            alumnos: [],
            profesores: [],
            estado: '',
            ciudad: '',
            pasosASeguir: {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar usuario "),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              widget.user.name = _nameController.text;
              widget.user.surname = _surnameController.text;
              widget.user.email = _emailController.text;
              widget.user.country = _countryController.text;
              widget.user.password = _passwordController.text;
              widget.user.phone = _phoneController.text;
              fd.addOrUpdateUser(widget.user);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CoordinadoresAdmin(),
                  ));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Información del Coordinador'.toUpperCase(),
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              TextFormField(
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal),
                decoration: InputDecoration(
                    labelText: 'Name',
                    icon: Icon(Icons.person),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.lightBlue))),
                controller: _nameController,
              ),
              TextFormField(
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal),
                decoration: InputDecoration(
                    labelText: 'Surname',
                    icon: Icon(Icons.person),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.lightBlue))),
                controller: _surnameController,
              ),
              TextFormField(
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal),
                decoration: InputDecoration(
                  labelText: 'Email',
                  icon: Icon(Icons.email),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightBlue)),
                ),
                enabled: false,
                controller: _emailController,
              ),
              TextFormField(
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal),
                decoration: InputDecoration(
                  labelText: 'Phone',
                  icon: Icon(Icons.phone),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightBlue)),
                ),
                controller: _phoneController,
              ),
              TextFormField(
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal),
                decoration: InputDecoration(
                  labelText: 'Country',
                  icon: Icon(Icons.location_city),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightBlue)),
                ),
                controller: _countryController,
              ),
              TextFormField(
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal),
                decoration: InputDecoration(
                  labelText: 'Password',
                  icon: Icon(Icons.lock),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightBlue)),
                ),
                controller: _passwordController,
                enabled: false,
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 10)),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue[100],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Alumnos presentados',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    FutureBuilder<String>(
                      future: _contarAlumnos(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            snapshot.data!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error al obtener el número de alumnos');
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    ),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 10)),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue[100],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Text(
                        'Presupuestos',
                        maxLines: null,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: FutureBuilder<double>(
                        future: getTotalApprovedBudget(_emailController.text),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // Muestra un indicador de carga mientras se obtiene el total del presupuesto
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            // Muestra un mensaje de error si ocurre algún problema
                            return Text('Error: ${snapshot.error}');
                          } else {
                            // Obtiene el total del presupuesto aprobado del snapshot
                            final totalBudget = snapshot.data;

                            return Text(
                              ' $totalBudget',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              SizedBox(height: 16),
              ExpansionTile(
                title: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Proyectos presentados'.toUpperCase(),
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                children: _proyectos.map((Proyecto proyecto) {
                  return ListTile(
                    title: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: _getColorFromProjectState(proyecto.estado),
                        ),
                        child: Text(
                          proyecto.name,
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.normal),
                        )),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ProyectosAdminEdit(proyecto: proyecto),
                      ));
                      setState(() {
                        _selectedProyecto = proyecto;
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> _contarAlumnos() async {
    List<Proyecto> proyectos =
        await fd.getAllProjectsByUser(_emailController.text);
    int sumaAlumnos = 0;
    for (var p in proyectos) {
      if (p.estado.contains('aprobado')) {
        sumaAlumnos += p.alumnos.length;
      }
    }
    return sumaAlumnos.toString();
  }

  Future<double> getTotalApprovedBudget(String userId) async {
    double totalBudget = 0.0;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data();

    final List<dynamic> proyectos = userData?['proyectos'] ?? [];

    for (final proyecto in proyectos) {
      if (proyecto['estado'] == 'aprobado') {
        final budget = proyecto['presupuesto'];
        totalBudget += budget;
      }
    }

    return totalBudget;
  }

  Color _getColorFromProjectState(String projectState) {
    switch (projectState) {
      case 'pendiente':
        return Colors.brown[100]!;
      case 'aprobado':
        return Colors.lightGreen[100]!;
      case 'rechazado':
        return Colors.red[100]!;
      default:
        return Colors.white;
    }
  }
}
