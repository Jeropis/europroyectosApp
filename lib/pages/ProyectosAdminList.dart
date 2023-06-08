import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Classes/Proyecto.dart';
import '../DAO/FirestoreDao.dart';
import '../Widgets/NavigationMenu.dart';
import 'ProyectosAdminEdit.dart';

class ProyectosAdminList extends StatefulWidget {
  const ProyectosAdminList({Key? key});

  @override
  State<ProyectosAdminList> createState() => _ProyectosAdminList();
}

class _ProyectosAdminList extends State<ProyectosAdminList> {
  List<Proyecto> proyectos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarProyectos();
  }

  Future<void> _cargarProyectos() async {
    FirestoreDao dao = FirestoreDao();
    List<Proyecto> proyectos = await dao.getAllProjects();
    proyectos.sort((a, b) => a.fechaInicio.compareTo(b.fechaInicio));
    setState(() {
      this.proyectos = proyectos;
      isLoading = false;
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
          drawer: NavigationMenu(),
          appBar: AppBar(
            title: const Text("Proyectos"),
            backgroundColor: Colors.lightBlue,
          ),
          body: isLoading
              ? SingleChildScrollView(
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Column(
                  children: [
                    _buildHeader(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Resto del código
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          // ExpansionTile para proyectos aceptados
                          ExpansionTile(
                            title: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Proyectos Aceptados',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            children: [
                              for (var proyecto in proyectos)
                                if (proyecto.estado == 'aprobado' &&
                                    proyecto.fechaInicio
                                        .isAfter(DateTime.now()))
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (_) => ProyectosAdminEdit(
                                            proyecto: proyecto),
                                      ));
                                    },
                                    child: ListTile(
                                      title: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.green[100],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                flex: 1,
                                                child: Text(
                                                  proyecto.name,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.normal),
                                                  maxLines: null,
                                                ),
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 40)),
                                              Text(
                                                '${DateFormat('dd/MM/yyyy').format(proyecto.fechaInicio)}',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'Poppins',
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ],
                                          )),
                                      trailing: Icon(Icons.arrow_forward_ios),
                                    ),
                                  ),
                            ],
                          ),
                          // ExpansionTile para proyectos en espera
                          Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                          ExpansionTile(
                            title: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Proyectos en Espera',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            children: [
                              for (var proyecto in proyectos)
                                if (proyecto.estado == 'pendiente')
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (_) => ProyectosAdminEdit(
                                            proyecto: proyecto),
                                      ));
                                    },
                                    child: ListTile(
                                      title: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.brown[100],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                flex: 1,
                                                child: Text(
                                                  proyecto.name,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.normal),
                                                  maxLines: null,
                                                ),
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 40)),
                                              Text(
                                                '${DateFormat('dd/MM/yyyy').format(proyecto.fechaInicio)}',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'Poppins',
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ],
                                          )),
                                      trailing: Icon(Icons.arrow_forward_ios),
                                    ),
                                  ),
                            ],
                          ),
                          // ExpansionTile para proyectos rechazados
                          Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                          ExpansionTile(
                            title: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Proyectos Rechazados',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            children: [
                              for (var proyecto in proyectos)
                                if (proyecto.estado == 'rechazado')
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (_) => ProyectosAdminEdit(
                                            proyecto: proyecto),
                                      ));
                                    },
                                    child: ListTile(
                                      title: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.red[100],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                flex: 1,
                                                child: Text(
                                                  proyecto.name,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.normal),
                                                  maxLines: null,
                                                ),
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 40)),
                                              Text(
                                                '${DateFormat('dd/MM/yyyy').format(proyecto.fechaInicio)}',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'Poppins',
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ],
                                          )),
                                      trailing: Icon(Icons.arrow_forward_ios),
                                    ),
                                  ),
                            ],
                          ),
                          Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                          ExpansionTile(
                            title: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Proyectos en Curso',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            children: [
                              for (var proyecto in proyectos)
                                if (proyecto.estado == 'aprobado' &&
                                    (proyecto.fechaInicio
                                            .isBefore(DateTime.now()) &&
                                        proyecto.fechaFin
                                            .isAfter(DateTime.now())))
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (_) => ProyectosAdminEdit(
                                            proyecto: proyecto),
                                      ));
                                    },
                                    child: ListTile(
                                      title: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.green[100],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                flex: 1,
                                                child: Text(
                                                  proyecto.name,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.normal),
                                                  maxLines: null,
                                                ),
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 40)),
                                              Text(
                                                '${DateFormat('dd/MM/yyyy').format(proyecto.fechaInicio)}',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'Poppins',
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ],
                                          )),
                                      trailing: Icon(Icons.arrow_forward_ios),
                                    ),
                                  ),
                            ],
                          ),
                          Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                          ExpansionTile(
                            title: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Proyectos Finalizados',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                            children: [
                              for (var proyecto in proyectos)
                                if (proyecto.estado == 'aprobado' &&
                                    proyecto.fechaFin.isBefore(DateTime.now()))
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (_) => ProyectosAdminEdit(
                                            proyecto: proyecto),
                                      ));
                                    },
                                    child: ListTile(
                                      title: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.green[100],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                flex: 1,
                                                child: Text(
                                                  proyecto.name,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.normal),
                                                  maxLines: null,
                                                ),
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 40)),
                                              Text(
                                                '${DateFormat('dd/MM/yyyy').format(proyecto.fechaInicio)}',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'Poppins',
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ],
                                          )),
                                      trailing: Icon(Icons.arrow_forward_ios),
                                    ),
                                  )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ));
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
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
            Icons.work,
            color: Colors.black45,
            size: 32,
          ),
          const SizedBox(width: 16),
          Text(
            'Administrar Proyectos',
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
}
