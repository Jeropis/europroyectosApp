import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Classes/Alumno.dart';
import '../Classes/Profesor.dart';
import '../Classes/Proyecto.dart';
import '../Classes/Usuario.dart';
import '../DAO/FirestoreDao.dart';

class ProjectDetailsPage extends StatefulWidget {
  final Proyecto project;

  ProjectDetailsPage({required this.project});

  @override
  _ProjectDetailsPageState createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController coordinadorController = TextEditingController();
  TextEditingController presupuestoController = TextEditingController();
  TextEditingController fechaInicioController = TextEditingController();
  TextEditingController fechaFinController = TextEditingController();
  final ciudad = TextEditingController();
  String selectedCity = '';
  List<Map<String, dynamic>> alumnosMap = [];
  List<Map<String, dynamic>> profesoresMap = [];
  DateTime _selectedDateI = DateTime.now();
  DateTime _selectedDateF = DateTime.now();
  late List<Alumno> alumnos = convertirAlumnos(widget.project.alumnos);
  late List<Profesor> profesores =
      convertirProfesores(widget.project.profesores);
  List<String> cities = [
    'Martos',
    'Málaga',
    'Granada',
    'Córdoba'
    // Agrega más ciudades según tus necesidades
  ];
  late Future<List<Usuario>> listaUsuarios;
  FirestoreDao dao = FirestoreDao();
  bool dniOk = false;

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.text.isNotEmpty
          ? DateFormat.yMd().parse(controller.text)
          : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) controller.text = DateFormat.yMd().format(picked);
    _selectedDateI = picked!;
  }

  Future<void> _selectDateF(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.text.isNotEmpty
          ? DateFormat.yMd().parse(controller.text)
          : DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat.yMd().format(picked);
      _selectedDateF = picked;
    }
  }

  @override
  void initState() {
    super.initState();
    nameController.text = widget.project.name;
    descripcionController.text = widget.project.descripcion;
    fechaInicioController.text =
        DateFormat.yMd().format(widget.project.fechaInicio);
    fechaFinController.text = DateFormat.yMd().format(widget.project.fechaFin);
    coordinadorController.text = widget.project.coordinador;
    presupuestoController.text = widget.project.presupuesto.toString();
    ciudad.text = widget.project.ciudad.toString();
    listaUsuarios = dao.getUsers();
    _selectedDateI = widget.project.fechaInicio;
    _selectedDateF = widget.project.fechaFin;
  }

  @override
  void dispose() {
    // Limpiar los controladores de texto al salir de la página
    nameController.dispose();
    descripcionController.dispose();
    coordinadorController.dispose();
    presupuestoController.dispose();
    fechaInicioController.dispose();
    fechaFinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              // Guardar los cambios realizados en el proyecto
              widget.project.name = nameController.text;
              widget.project.descripcion = descripcionController.text;
              widget.project.coordinador = coordinadorController.text;
              widget.project.presupuesto =
                  double.parse(presupuestoController.text);
              widget.project.ciudad = ciudad.text;

              widget.project.fechaInicio = _selectedDateI;
              widget.project.fechaFin = _selectedDateF;
              widget.project.alumnos.clear();
              widget.project.profesores.clear();
              for (var alumno in alumnos) {
                final nombre = alumno.name;
                final apellido = alumno.surname;
                final nif = alumno.nif;

                bool existe =
                    widget.project.alumnos.any((al) => al['nif'] == nif);
                if (existe) {
                } else {
                  Map<String, dynamic> alumnoMap = {
                    'name': nombre,
                    'surname': apellido,
                    'nif': nif,
                    'phone': alumno.phone,
                    'email': alumno.email,
                  };
                  widget.project.alumnos.add(alumnoMap);
                }
              }
              for (var profesor in profesores) {
                // Obtener los datos del alumno
                final nombre = profesor.name;
                final apellido = profesor.surname;
                final nif = profesor.nif;

                // Verificar si el alumno ya existe en la lista widget.project.alumnos
                bool existe =
                    widget.project.profesores.any((al) => al['nif'] == nif);
                if (existe) {
                } else {
                  Map<String, dynamic> profesorMap = {
                    'name': nombre,
                    'surname': apellido,
                    'nif': nif,
                    'phone': profesor.phone,
                    'email': profesor.email,
                  };
                  widget.project.profesores.add(profesorMap);
                }
              }
              List<Proyecto> lista = [];
              lista.add(widget.project);
              // Actualizar el proyecto en la base de datos

              dao.addOrUpdateProjects(widget.project.coordinador, lista);
              List<Usuario> listaUsuariosA = await listaUsuarios;
              String nombreUsuario = '';
              for (var u in listaUsuariosA) {
                if (u.email == widget.project.coordinador) {
                  nombreUsuario = u.name;
                }
              }
              for (var u in listaUsuariosA) {
                if (u.isAdmin) {
                  sendPushNotification(
                      u.token,
                      '$nombreUsuario ha modificado un proyecto',
                      '$nombreUsuario ha modificado el proyecto con nombre: ${widget.project.name}');
                }
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Proyecto actualizado')),
              );
            },
          ),
        ],
        title: Text('Detalles del Proyecto'),
      ),
      body: Scrollbar(
        thickness: 8, // Grosor de la barra
        radius: Radius.circular(10), // Radio de las esquinas de la barra
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.all(16.0),
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
                      'Información del proyecto'.toUpperCase(),
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
                controller: nameController,
                decoration: InputDecoration(
                  icon: Icon(Icons.abc),
                  labelText: 'Nombre del proyecto',
                  labelStyle: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // ajusta el color a tu preferencia
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors
                            .grey[500]!), // ajusta el color a tu preferencia
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue), // ajusta el color a tu preferencia
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.normal,
                ),
                enabled: false,
              ),
              TextFormField(
                controller: descripcionController,
                decoration: InputDecoration(
                  labelText: 'Número de referencia',
                  icon: Icon(Icons.numbers),
                  labelStyle: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // ajusta el color a tu preferencia
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors
                            .grey[500]!), // ajusta el color a tu preferencia
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue), // ajusta el color a tu preferencia
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.normal,
                ),
                enabled: false,
              ),
              TextFormField(
                controller: fechaInicioController,
                decoration: InputDecoration(
                  icon: Icon(Icons.edit_calendar_outlined),
                  labelText: 'Fecha de inicio (mm/dd/yyyy)',
                  labelStyle: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // ajusta el color a tu preferencia
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors
                            .grey[500]!), // ajusta el color a tu preferencia
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue), // ajusta el color a tu preferencia
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.normal,
                ),
                readOnly: true,
                onTap: () => _selectDate(context, fechaInicioController),
              ),
              TextFormField(
                controller: fechaFinController,
                decoration: InputDecoration(
                  labelText: 'Fecha de fin (mm/dd/yyyy)',
                  icon: Icon(Icons.edit_calendar_outlined),
                  labelStyle: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // ajusta el color a tu preferencia
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors
                            .grey[500]!), // ajusta el color a tu preferencia
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue), // ajusta el color a tu preferencia
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.normal,
                ),
                readOnly: true,
                onTap: () => _selectDate(context, fechaFinController),
              ),
              TextFormField(
                controller: presupuestoController,
                decoration: InputDecoration(
                  labelText: 'Presupuesto',
                  icon: Icon(Icons.attach_money),
                  labelStyle: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // ajusta el color a tu preferencia
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors
                            .grey[500]!), // ajusta el color a tu preferencia
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue), // ajusta el color a tu preferencia
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.normal,
                ),
                keyboardType:
                    TextInputType.number, // Mostrará un teclado numérico
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
              ),
              TextFormField(
                controller: ciudad,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Ciudad',
                  labelStyle: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    color: Colors.grey[700],
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.normal,
                ),
              ),
              Row(
                children: [
                  PopupMenuButton<String>(
                    icon: Icon(Icons.arrow_drop_down),
                    itemBuilder: (BuildContext context) {
                      return cities.map((String city) {
                        return PopupMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList();
                    },
                    onSelected: (String value) {
                      setState(() {
                        selectedCity = value;
                        ciudad.text = value;
                      });
                    },
                  )
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 20)),
              Column(children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 50),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text(
                        'Alumnos',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String name = "";
                              String surname = "";
                              String nif = "";
                              String phone = "";
                              String email = "";
                              return _alertDialogAlumnos(
                                  context, name, surname, nif, phone, email);
                            },
                          );
                        },
                        icon: Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                ),
                Divider(),
                Padding(padding: EdgeInsets.only(top: 10)),
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(height: 5); // Espacio entre elementos
                    },
                    itemCount: alumnos.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue[100]!),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset:
                                  Offset(0, 2), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                alumnos[index].name +
                                    ' ' +
                                    alumnos[index].surname,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  alumnos.removeAt(index);
                                });
                              },
                              icon: Icon(CupertinoIcons.delete),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                )
              ]),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 50),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      'Profesores',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            String nameP = "";
                            String surnameP = "";
                            String nifP = "";
                            String phoneP = "";
                            String emailP = "";
                            return _alertDialogProfesores(
                                context, nameP, surnameP, nifP, phoneP, emailP);
                          },
                        );
                      },
                      icon: Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ),
              Divider(),
              Padding(padding: EdgeInsets.only(top: 10)),
              SizedBox(
                height: 200,
                child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(height: 5); // Espacio entre elementos
                    },
                    itemCount: profesores.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue[100]!),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset:
                                  Offset(0, 2), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                profesores[index].name +
                                    ' ' +
                                    profesores[index].surname,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  profesores.removeAt(index);
                                });
                              },
                              icon: Icon(CupertinoIcons.delete),
                            )
                          ],
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AlertDialog _alertDialogProfesores(BuildContext context, String name,
      String surname, String nif, String phone, String email) {
    return AlertDialog(
      title: const Text(
        'Agregar Profesor',
        style: TextStyle(
          fontSize: 22,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        height: MediaQuery.of(context).size.height / 2,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  name = value;
                },
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Apellido',
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  surname = value;
                },
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'NIF',
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  nif = value;
                },
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  phone = value;
                },
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  email = value;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text(
            'Cancelar',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text(
            'Agregar',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
            ),
          ),
          onPressed: () {
            if (name.isEmpty ||
                surname.isEmpty ||
                nif.isEmpty ||
                phone.isEmpty ||
                email.isEmpty) {
              Fluttertoast.showToast(
                msg: "Rellene todos los campos",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 12.0,
              );
            } else {
              Profesor prof = Profesor(
                name: name,
                surname: surname,
                nif: nif,
                phone: phone,
                email: email,
              );
              setState(() {
                for (var pActual in profesores) {
                  if (pActual.nif == prof.nif) {
                    dniOk = false;
                  } else {
                    dniOk = true;
                  }
                  for (var aActual in alumnos) {
                    if (aActual.nif == (prof.nif)) {
                      dniOk = false;
                    } else {
                      dniOk = true;
                    }
                  }
                }
                if (profesores.isEmpty || dniOk) {
                  profesores.add(prof);
                } else {
                  Fluttertoast.showToast(
                    msg: "No puede haber dos NIF iguales",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 12.0,
                  );
                }
              });
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  AlertDialog _alertDialogAlumnos(BuildContext context, String name,
      String surname, String nif, String phone, String email) {
    return AlertDialog(
      title: const Text(
        'Agregar Alumno',
        style: TextStyle(
          fontSize: 22,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        height: MediaQuery.of(context).size.height / 2,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  name = value;
                },
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Apellido',
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  surname = value;
                },
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'NIF',
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  nif = value;
                },
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  phone = value;
                },
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  email = value;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text(
            'Cancelar',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text(
            'Agregar',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
            ),
          ),
          onPressed: () {
            if (name.isEmpty ||
                surname.isEmpty ||
                nif.isEmpty ||
                phone.isEmpty ||
                email.isEmpty) {
              Fluttertoast.showToast(
                msg: "Rellene todos los campos",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 12.0,
              );
            } else {
              Alumno al = Alumno(
                name: name,
                surname: surname,
                nif: nif,
                phone: phone,
                email: email,
              );

              setState(() {
                for (var pActual in alumnos) {
                  if (pActual.nif == al.nif) {
                    dniOk = false;
                  } else {
                    dniOk = true;
                  }
                  for (var aActual in profesores) {
                    if (aActual.nif == (al.nif)) {
                      dniOk = false;
                    } else {
                      dniOk = true;
                    }
                  }
                }
                if (alumnos.isEmpty || dniOk) {
                  alumnos.add(al);
                } else {
                  Fluttertoast.showToast(
                    msg: "No puede haber dos NIF iguales",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 12.0,
                  );
                }
              });
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  List<Alumno> convertirAlumnos(List<Map<String, dynamic>> alumnos) {
    return alumnos.map((alumno) {
      return Alumno(
        name: alumno['name'],
        surname: alumno['surname'],
        nif: alumno['nif'],
        phone: alumno['phone'],
        email: alumno['email'],
      );
    }).toList();
  }

  List<Profesor> convertirProfesores(List<Map<String, dynamic>> profesores) {
    return profesores.map((profesor) {
      return Profesor(
        name: profesor['name'],
        surname: profesor['surname'],
        nif: profesor['nif'],
        phone: profesor['phone'],
        email: profesor['email'],
      );
    }).toList();
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
