import 'dart:convert';
import 'dart:ffi';
import 'package:europroyectos_app/Classes/Profesor.dart';
import 'package:europroyectos_app/Widgets/CoordinatorNavigationMenu.dart';
import 'package:europroyectos_app/pages/CoordinatorHomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../Classes/Alumno.dart';
import '../Classes/Proyecto.dart';
import '../Classes/Usuario.dart';
import '../DAO/FirestoreDao.dart';
import '../Widgets/NavigationMenu.dart';
import 'CoordinadoresAdmin.dart';
import 'package:http/http.dart' as http;

class NewProject extends StatefulWidget {
  const NewProject({super.key});

  @override
  State<NewProject> createState() => NewProjectPageState();
}

class NewProjectPageState extends State<NewProject> {
  TextEditingController _textNameController = TextEditingController();
  final name = TextEditingController();
  final surname = TextEditingController();
  final country = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final phone = TextEditingController();
  final descripcion = TextEditingController();
  final pName = TextEditingController();
  final presupuesto = TextEditingController();
  final ciudad = TextEditingController();
  List<Map<String, dynamic>> alumnosMap = [];
  List<Map<String, dynamic>> profesoresMap = [];
  Map<String, bool> pasosASeguirMap = {};
  final DateTime fechaISel = DateTime.now();
  final DateTime fechaFSel = DateTime.now();
  List<Alumno> alumnos = [];
  List<Profesor> profesores = [];
  DateTime _selectedDateI = DateTime.now();
  DateTime _selectedDateF = DateTime.now();
  bool isCompleted = false;
  int currentStep = 0;
  bool nombreOk = true;
  late Future<List<Proyecto>> listaProyectos;
  late Future<List<Usuario>> listaUsuarios;
  String selectedCity = ''; // Variable para almacenar la ciudad seleccionada
  bool dniOk = false;

// Lista de ciudades disponibles para seleccionar
  List<String> cities = [
    'Martos',
    'Málaga',
    'Granada',
    'Córdoba'
    // Agrega más ciudades según tus necesidades
  ];

  @override
  void initState() {
    super.initState();
    FirestoreDao fd = FirestoreDao();
    listaProyectos = fd.getAllProjects();
    listaUsuarios = fd.getUsers();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
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
          drawer: CoordinatorNavigationMenu(),
          appBar: AppBar(
            title: const Text("Nuevo Proyecto"),
            backgroundColor: Colors.lightBlue,
          ),
          body: isCompleted
              ? buildCompleted()
              : Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(primary: Colors.red),
                  ),
                  child: Stepper(
                    steps: getSteps(),
                    currentStep: currentStep,
                    onStepContinue: () async {
                      final isLastStep = currentStep == 3;

                      List<Proyecto> listaProyectosA = await listaProyectos;

                      for (var p in listaProyectosA) {
                        if (pName.text == p.name) {
                          nombreOk = false;
                        }
                      }
                      if (nombreOk) {
                        if (isLastStep &&
                            pName.text.isNotEmpty &&
                            descripcion.text.isNotEmpty &&
                            presupuesto.text.isNotEmpty &&
                            alumnos.isNotEmpty &&
                            profesores.isNotEmpty) {
                          if (!_selectedDateI
                                  .isAtSameMomentAs(DateTime.now()) &&
                              _selectedDateF.isAfter(_selectedDateI)) {
                            setState(() => isCompleted = true);

                            List<Proyecto> lista = [];
                            for (var a in alumnos) {
                              alumnosMap.add(a.toMap());
                            }
                            for (var p in profesores) {
                              profesoresMap.add(p.toMap());
                            }
                            FirestoreDao dao = FirestoreDao();
                            setState(() {
                              pasosASeguirMap['acuerdoMovilidad'] = false;
                              pasosASeguirMap['primerPago'] = false;
                              pasosASeguirMap['participantes'] = false;
                              pasosASeguirMap['copiasDni'] = false;
                              pasosASeguirMap['curriculums'] = false;
                              pasosASeguirMap['vuelos'] = false;
                              pasosASeguirMap['segundoPago'] = false;
                              pasosASeguirMap['acuerdoPracticas'] = false;
                              pasosASeguirMap['copiaSeguro'] = false;
                              pasosASeguirMap['habitaciones'] = false;
                              pasosASeguirMap['disseminationPlan'] = false;
                            });

                            User? cu = FirebaseAuth.instance.currentUser;
                            if (cu != null) {
                              Proyecto cuP = Proyecto(
                                  id: '1',
                                  name: pName.text,
                                  descripcion: descripcion.text,
                                  fechaInicio: _selectedDateI,
                                  fechaFin: _selectedDateF,
                                  coordinador: cu.email!,
                                  presupuesto: double.parse(presupuesto.text),
                                  alumnos: alumnosMap,
                                  profesores: profesoresMap,
                                  estado: 'pendiente',
                                  ciudad: ciudad.text,
                                  pasosASeguir: pasosASeguirMap);
                              lista.add(cuP);
                              List<Usuario> listaUsuariosA =
                                  await listaUsuarios;
                              String nombreUsuario = '';
                              for (var u in listaUsuariosA) {
                                if (u.email == cu.email) {
                                  nombreUsuario = u.name;
                                }
                              }
                              for (var u in listaUsuariosA) {
                                if (u.isAdmin) {
                                  sendPushNotification(
                                      u.token,
                                      '$nombreUsuario ha creado un nuevo proyecto',
                                      '$nombreUsuario ha creado un proyecto con nombre: ${pName.text}');
                                }
                              }

                              dao.addOrUpdateProjects(cu.email!, lista);
                            }
                          } else {
                            Fluttertoast.showToast(
                              msg: "Las fechas no son válidas",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 12.0,
                            );
                          }
                        } else if (!isLastStep) {
                          setState(() => currentStep += 1);
                        } else {
                          if (alumnos.isEmpty) {
                            Fluttertoast.showToast(
                              msg: "Tienes que poner al menos un alumno.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 12.0,
                            );
                          } else if (profesores.isEmpty) {
                            Fluttertoast.showToast(
                              msg: "Tienes que poner al menos un profesor.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 12.0,
                            );
                          } else {
                            Fluttertoast.showToast(
                              msg: "No puedes dejar campos vacíos.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 12.0,
                            );
                          }
                        }
                      } else {
                        Fluttertoast.showToast(
                          msg: "El nombre del proyecto debe ser único",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 12.0,
                        );
                        nombreOk = true;
                      }
                    },
                    onStepCancel: currentStep == 0
                        ? null
                        : () => setState(() => currentStep -= 1),
                    controlsBuilder: (BuildContext context,
                        ControlsDetails controlsDetails) {
                      return Container(
                        padding: const EdgeInsets.only(top: 50),
                        child: Row(
                          children: [
                            ElevatedButton.icon(
                                onPressed: controlsDetails.onStepContinue,
                                label: Text(
                                  'Continuar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                icon: Icon(CupertinoIcons.arrow_right)),
                            ElevatedButton.icon(
                                onPressed: controlsDetails.onStepCancel,
                                label: Text(
                                  'Volver',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                icon: Icon(CupertinoIcons.xmark_circle)),
                          ],
                        ),
                      );
                    },
                  ),
                )));

  List<Step> getSteps() => [
        Step(
            state: currentStep > 0 ? StepState.complete : StepState.indexed,
            isActive: currentStep >= 0,
            title: Text("Datos Proyecto"),
            content: Column(
              children: [
                TextFormField(
                  controller: pName,
                  decoration: InputDecoration(
                    labelText: 'Nombre del proyecto',
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                      color:
                          Colors.grey[700], // ajusta el color a tu preferencia
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors
                              .grey[500]!), // ajusta el color a tu preferencia
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Colors.blue), // ajusta el color a tu preferencia
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                  ),
                ),
                TextFormField(
                  controller: descripcion,
                  decoration: InputDecoration(
                    labelText: 'Número referencia ',
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                      color:
                          Colors.grey[700], // ajusta el color a tu preferencia
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors
                              .grey[500]!), // ajusta el color a tu preferencia
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Colors.blue), // ajusta el color a tu preferencia
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                  ),
                ),
                TextFormField(
                  controller: presupuesto,
                  decoration: InputDecoration(
                    labelText: 'Presupuesto',
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                      color:
                          Colors.grey[700], // ajusta el color a tu preferencia
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors
                              .grey[500]!), // ajusta el color a tu preferencia
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color:
                              Colors.blue), // ajusta el color a tu preferencia
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
                )
              ],
            )),
        Step(
            state: currentStep > 1 ? StepState.complete : StepState.indexed,
            isActive: currentStep >= 1,
            title: Text("Fechas"),
            content: Column(
              children: [
                Column(
                  children: [
                    Text(
                      'Fecha de inicio seleccionada',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${DateFormat.yMd().format(_selectedDateI)}",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _selectDateI(context);
                    setState(() {
                      _selectedDateI = fechaISel;
                    });
                  },
                  label: Text(
                    'Selecciona una fecha de inicio',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.normal,
                        color: Colors.black),
                  ),
                  icon: Icon(
                    CupertinoIcons.calendar,
                    color: Colors.black,
                  ),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.lightBlue)),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                Column(
                  children: [
                    Text(
                      'Fecha de fin seleccionada',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${DateFormat.yMd().format(_selectedDateF)}",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _selectDateF(context);
                    setState(() {
                      _selectedDateF = fechaFSel;
                    });
                  },
                  label: Text(
                    'Selecciona una fecha de fin',
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.normal,
                        color: Colors.black),
                  ),
                  icon: Icon(
                    CupertinoIcons.calendar,
                    color: Colors.black,
                  ),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.lightBlue)),
                )
              ],
            )),
        Step(
          state: currentStep > 2 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 2,
          title: Text("Alumnos"),
          content: Column(
            children: [
              Text(
                'Alumnos',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              Divider(),
              Padding(padding: EdgeInsets.only(top: 20)),
              SizedBox(
                height: 200,
                child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(height: 5); // Espacio entre elementos
                  },
                  itemCount: alumnos.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: Offset(0, 2), // changes position of shadow
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
                                fontWeight: FontWeight.bold,
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
              ),
              Padding(padding: EdgeInsets.only(top: 20)),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      String name = "";
                      String surname = "";
                      String nif = "";
                      String phone = "";
                      String email = "";
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
                                Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5)),
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
                                Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5)),
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
                                Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5)),
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
                                Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5)),
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
                                setState(() {
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
                    },
                  );
                },
                icon: Icon(
                  CupertinoIcons.plus_circle,
                  color: Colors.black,
                ),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.lightBlue)),
                label: const Text(
                  'Agregar Alumno',
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        Step(
            state: currentStep > 3 ? StepState.complete : StepState.indexed,
            isActive: currentStep >= 3,
            title: Text("Profesores"),
            content: Column(children: [
              Text(
                'Profesores',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              Divider(),
              Padding(padding: EdgeInsets.only(top: 20)),
              SizedBox(
                height: 200,
                child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(height: 5); // Espacio entre elementos
                    },
                    itemCount: profesores.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
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
                                  fontWeight: FontWeight.bold,
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
              Padding(padding: EdgeInsets.only(top: 20)),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      String nameP = "";
                      String surnameP = "";
                      String nifP = "";
                      String phoneP = "";
                      String emailP = "";
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
                                    nameP = value;
                                  },
                                ),
                                Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5)),
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
                                    surnameP = value;
                                  },
                                ),
                                Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5)),
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
                                    nifP = value;
                                  },
                                ),
                                Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5)),
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
                                    phoneP = value;
                                  },
                                ),
                                Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5)),
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
                                    emailP = value;
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
                              if (nameP.isEmpty ||
                                  surnameP.isEmpty ||
                                  nifP.isEmpty ||
                                  phoneP.isEmpty ||
                                  emailP.isEmpty) {
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
                                  name: nameP,
                                  surname: surnameP,
                                  nif: nifP,
                                  phone: phoneP,
                                  email: emailP,
                                );

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
                                setState(() {
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
                    },
                  );
                },
                icon: Icon(
                  CupertinoIcons.plus_circle,
                  color: Colors.black,
                ),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.lightBlue)),
                label: const Text(
                  'Agregar Profesor',
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
              ),
            ]))
      ];

  void _selectDateI(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDateI,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    if (picked != null && picked != _selectedDateI) {
      setState(() {
        _selectedDateI = picked;
      });
    }
  }

  void showCityMenu(BuildContext context) {
    final List<String> cities = [
      'Martos',
      'Málaga',
      'Granada',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selecciona una ciudad'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: cities.map((city) {
              return ListTile(
                title: Text(city),
                onTap: () {
                  Navigator.of(context).pop(city);
                },
              );
            }).toList(),
          ),
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedCity = value;
        });
      }
    });
  }

  void _selectDateF(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDateF,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    if (picked != null && picked != _selectedDateF) {
      setState(() {
        _selectedDateF = picked;
      });
    }
  }

  Widget buildCompleted() {
    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text(
              'Proyecto registrado correctamente',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.normal,
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 52)),
            Image.asset(
              'assets/comprobado.png',
              width: 200,
              height: 200,
            ),
            const Padding(padding: EdgeInsets.only(top: 52)),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const CoordinatorHomePage()));
                },
                child: Text(
                  'Volver',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.normal,
                  ),
                )),
          ])),
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
