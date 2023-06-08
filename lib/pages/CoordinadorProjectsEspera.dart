import 'package:europroyectos_app/Pages/ProjectDetailsPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../Classes/Proyecto.dart';
import '../DAO/FirestoreDao.dart';
import '../Widgets/CoordinatorNavigationMenu.dart';
import 'ProjectsStepsCoordinator.dart';

class CoordinadorProjectsEspera extends StatefulWidget {
  @override
  _CoordinadorApprovedProjectsPageState createState() =>
      _CoordinadorApprovedProjectsPageState();
}

class _CoordinadorApprovedProjectsPageState
    extends State<CoordinadorProjectsEspera> {
  List<Proyecto> proyectosAprobados = [];

  @override
  void initState() {
    super.initState();
    fetchApprovedProjects();
  }

  Future<void> fetchApprovedProjects() async {
    // Aquí debes obtener los proyectos aprobados del coordinador actual desde tu fuente de datos (por ejemplo, Firestore)
    // Puedes modificar el método `getApprovedProjectsByCoordinator` según tu implementación
    String? coordinatorId = 'ID_DEL_COORDINADOR_ACTUAL';
    FirestoreDao dao = FirestoreDao();
    if (FirebaseAuth.instance.currentUser?.email != null) {
      coordinatorId = FirebaseAuth.instance.currentUser?.email;
    }
    final projects = await dao.getAllProjectsByUser(coordinatorId!);
    for (var pro in projects) {
      if (pro.estado == 'pendiente') {
        setState(() {
          proyectosAprobados.add(pro);
        });
      }
    }
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
            title: Text('Proyectos Pendientes'),
          ),
          body: ListView.builder(
            itemCount: proyectosAprobados.length,
            itemBuilder: (context, index) {
              final proyecto = proyectosAprobados[index];
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
                                      ((contadorPasosTrue(
                                                      proyecto.pasosASeguir) *
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
                              )
                              // Puedes agregar más información del proyecto en el ListTile según tus necesidades
                              ),
                        ),
                      )));
            },
          ),
        ));
  }

  void _onDismissed(int index, String action) {
    if (action == 'delete') {
      final usuarioA = proyectosAprobados[index];
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
                  fontWeight: FontWeight.normal),
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
                  await fd.deleteProject(proyectosAprobados[index].coordinador,
                      proyectosAprobados[index].name);
                  setState(() => proyectosAprobados.removeAt(index));
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      final proyectoSelect = proyectosAprobados[index];
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
