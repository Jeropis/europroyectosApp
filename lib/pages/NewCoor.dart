import 'package:europroyectos_app/Classes/Proyecto.dart';
import 'package:europroyectos_app/Classes/Usuario.dart';
import 'package:europroyectos_app/DAO/FirestoreDao.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Widgets/CustomTextField.dart';
import '../Widgets/NavigationMenu.dart';
import 'CoordinadoresAdmin.dart';

class NewCoor extends StatefulWidget {
  const NewCoor({super.key});

  @override
  State<NewCoor> createState() => NewCoorPageState();
}

class NewCoorPageState extends State<NewCoor> {
  TextEditingController _textNameController = TextEditingController();
  final name = TextEditingController();
  final surname = TextEditingController();
  final country = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final phone = TextEditingController();
  bool isCompleted = false;
  int currentStep = 0;
  bool _obscureText = true;
  late Future<List<Usuario>> listUsuarios;

  @override
  void initState() {
    super.initState();

    FirestoreDao dao = FirestoreDao();
    listUsuarios = dao.getUsers();
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
          drawer: NavigationMenu(),
          appBar: AppBar(
            title: const Text(
              "Coordinadores",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.normal,
                fontSize: 22,
              ),
            ),
            backgroundColor: Colors.lightBlue,
          ),
          body: isCompleted
              ? buildCompleted()
              : Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(primary: Colors.red),
                  ),
                  child: Stepper(
                    type: StepperType.horizontal,
                    steps: getSteps(),
                    currentStep: currentStep,
                    onStepContinue: () async {
                      final isLastStep = currentStep == 2;
                      List<Usuario> listUsuariosA = await listUsuarios;
                      bool userOk = true;
                      for (var u in listUsuariosA) {
                        if (u.email == email.text) {
                          Fluttertoast.showToast(
                            msg: "El correo ya existe.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 12.0,
                          );
                          userOk = false;
                        }
                      }
                      if (userOk) {
                        if (isLastStep &&
                            name.text.isNotEmpty &&
                            surname.text.isNotEmpty &&
                            email.text.isNotEmpty &&
                            country.text.isNotEmpty &&
                            password.text.isNotEmpty) {
                          setState(() => isCompleted = true);
                          List<Proyecto> lista = [];
                          Usuario user = Usuario(
                              id: email.text,
                              name: name.text,
                              surname: surname.text,
                              email: email.text,
                              country: country.text,
                              password: password.text,
                              isAdmin: false,
                              proyectos: lista,
                              phone: phone.text,
                              token: '');
                          FirestoreDao dao = FirestoreDao();
                          dao.addOrUpdateUser(user);
                          final adminuser = FirebaseAuth.instance.currentUser;
                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .createUserWithEmailAndPassword(
                                  email: email.text, password: password.text);
                          Usuario admin =
                              await dao.getUser(adminuser!.email.toString());
                          UserCredential userCredentialAdmin =
                              await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                      email: admin.email,
                                      password: admin.password);
                        } else if (!isLastStep) {
                          setState(() => currentStep += 1);
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
                                style: TextStyle(color: Colors.black),
                              ),
                              icon: Icon(
                                CupertinoIcons.arrow_right,
                                color: Colors.green,
                              ),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.blue[100]!),
                                shape:
                                    MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        20), // Establecer el radio del borde
                                    side: BorderSide(
                                        color: Colors
                                            .black), // Establecer el color y grosor del borde
                                  ),
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.all(5)),
                            ElevatedButton.icon(
                              onPressed: controlsDetails.onStepCancel,
                              label: Text(
                                'Volver',
                                style: TextStyle(color: Colors.black),
                              ),
                              icon: Icon(
                                CupertinoIcons.xmark_circle,
                                color: Colors.red,
                              ),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.blue[100]!),
                                shape:
                                    MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        20), // Establecer el radio del borde
                                    side: BorderSide(
                                        color: Colors
                                            .black), // Establecer el color y grosor del borde
                                  ),
                                ),
                              ),
                            ),
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
            title: Text(
              "Datos",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
            ),
            content: Column(
              children: [
                TextFormField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ),
                TextFormField(
                  controller: surname,
                  decoration: InputDecoration(
                    labelText: 'Apellidos',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ),
                TextFormField(
                  controller: country,
                  decoration: InputDecoration(
                    labelText: 'Pais',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ),
                TextFormField(
                  controller: phone,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            )),
        Step(
            state: currentStep > 1 ? StepState.complete : StepState.indexed,
            isActive: currentStep >= 1,
            title: Text(
              "Email",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
            ),
            content: Column(
              children: [
                TextFormField(
                  controller: email,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ),
                TextFormField(
                  controller: password,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  obscureText: _obscureText,
                )
              ],
            )),
        Step(
            state: currentStep > 2 ? StepState.complete : StepState.indexed,
            isActive: currentStep >= 2,
            title: Text(
              "Completo",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
            ),
            content: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nombre',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    name.text,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Apellido',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    surname.text,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Pais',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    country.text,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Email',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    email.text,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Contraseña',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _obscureText ? '******' : password.text,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Phone',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    phone.text,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ))
      ];

  Widget buildCompleted() {
    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text(
              'Coordinador registrado correctamente',
              style: TextStyle(fontFamily: 'Poppins'),
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
                      builder: (context) => const CoordinadoresAdmin()));
                },
                child: Text('Volver')),
          ])),
    );
  }
}
