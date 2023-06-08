import 'package:europroyectos_app/Pages/ProjectsSteps.dart';
import 'package:europroyectos_app/Widgets/CoordinatorNavigationMenu.dart';
import 'package:europroyectos_app/pages/ProjectsStepsCoordinator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../Classes/Proyecto.dart';
import '../DAO/FirestoreDao.dart';
import 'ProjectDetailsPage.dart';

class CoordinadorProjects extends StatefulWidget {
  @override
  _CoordinadorProjectsPageState createState() =>
      _CoordinadorProjectsPageState();
}

class _CoordinadorProjectsPageState extends State<CoordinadorProjects> {
  List<Proyecto> proyectos = [];

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    String? coordinatorId = 'ID_DEL_COORDINADOR_ACTUAL';
    FirestoreDao dao = FirestoreDao();
    if (FirebaseAuth.instance.currentUser?.email != null) {
      coordinatorId = FirebaseAuth.instance.currentUser?.email;
    }
    final projects = await dao.getAllProjectsByUser(coordinatorId!);

    setState(() {
      proyectos = projects;
    });
  }

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
          drawer: CoordinatorNavigationMenu(),
          appBar: AppBar(
            title: Text(
              'Proyectos del Coordinador',
              style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold),
            ),
          ),
          body: ListView.builder(
            itemCount: proyectos.length,
            itemBuilder: (context, index) {
              final proyecto = proyectos[index];
              Color iconColor;
              switch (proyecto.estado) {
                case 'aprobado':
                  iconColor = Colors.green;
                  break;
                case 'pendiente':
                  iconColor = Colors.yellow;
                  break;
                case 'rechazado':
                  iconColor = Colors.red;
                  break;
                default:
                  iconColor = Colors.grey;
              }
              return Slidable(
                startActionPane:
                    ActionPane(motion: const StretchMotion(), children: [
                  Container(
                    child: SlidableAction(
                      backgroundColor: Colors.red,
                      icon: Icons.delete,
                      label: 'Eliminar',
                      onPressed: (context) => _onDismissed(index, 'delete'),
                    ),
                  )
                ]),
                endActionPane:
                    ActionPane(motion: const BehindMotion(), children: [
                  SlidableAction(
                    backgroundColor: Colors.green,
                    icon: Icons.edit,
                    label: 'Editar',
                    onPressed: (context) => _onDismissed(index, 'edit'),
                  )
                ]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue[100]!),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 5.0,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                        title: Text(
                          proyecto.name,
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          proyecto.descripcion,
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.normal),
                        ),
                        trailing: Icon(Icons.work, color: iconColor),
                        leading: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProjectsStepsCoordinator(
                                    proyecto: proyecto,
                                  ),
                                ));
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: Text(
                              '' +
                                  ((contadorPasosTrue(proyecto.pasosASeguir) *
                                              100) /
                                          11)
                                      .round()
                                      .toString() +
                                  '%',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )),
                    // Puedes agregar más información del proyecto en el ListTile según tus necesidades
                  ),
                ),
              );
            },
          ),
        ));
  }

  void _onDismissed(int index, String action) {
    if (action == 'delete') {
      final usuarioA = proyectos[index];
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Confirmar eliminación',
              style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold),
            ),
            content: Text(
              '¿Estás seguro que quieres eliminar este proyecto?',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.normal,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'No',
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                      color: Colors.blue),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  'Sí',
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                      color: Colors.blue),
                ),
                onPressed: () async {
                  final fd = FirestoreDao();
                  await fd.deleteProject(
                      proyectos[index].coordinador, proyectos[index].name);
                  setState(() => proyectos.removeAt(index));
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      final usuarioA = proyectos[index];
      final proyectoSelect = proyectos[index];
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailsPage(project: proyectoSelect),
          ));
    }
  }

  int contadorPasosTrue(Map<String, bool> map) {
    int count = 0;
    map.forEach((key, value) {
      if (value == true) {
        count++;
      }
    });
    return count;
  }
}
