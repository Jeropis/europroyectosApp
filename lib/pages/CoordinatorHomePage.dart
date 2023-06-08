import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:europroyectos_app/DAO/FirestoreDao.dart';
import 'package:europroyectos_app/Pages/NewProject.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../Classes/Proyecto.dart';
import '../Classes/Usuario.dart';
import '../Widgets/CoordinatorNavigationMenu.dart';

class CoordinatorHomePage extends StatefulWidget {
  const CoordinatorHomePage({Key? key}) : super(key: key);

  @override
  _CoordinatorHomePageState createState() => _CoordinatorHomePageState();
}

class _CoordinatorHomePageState extends State<CoordinatorHomePage> {
  final fd = FirestoreDao();

  List<Usuario> usuarios = [];
  List<Proyecto> proyectos = [];
  int totalProyectos = 50;
  int proyectosAceptados = 20;
  int proyectosEnEspera = 10;
  int proyectosRechazados = 20;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarProyectos();
  }

  Future<void> _cargarProyectos() async {
    final user = FirebaseAuth.instance.currentUser;
    var emailUser = user!.email;
    FirestoreDao dao = FirestoreDao();
    int aceptadosCount = 0;
    int rechazadosCount = 0;
    int pendientesCount = 0;
    List<Proyecto> proyectos = await dao.getAllProjectsByUser(emailUser!);
    for (int i = 0; i < proyectos.length; i++) {
      if (proyectos[i].estado == "aprobado") {
        aceptadosCount += 1;
      }
      if (proyectos[i].estado == "rechazado") {
        rechazadosCount += 1;
      }
      if (proyectos[i].estado == "pendiente") {
        pendientesCount += 1;
      }
    }
    setState(() {
      proyectosAceptados = aceptadosCount;
      proyectosEnEspera = pendientesCount;
      proyectosRechazados = rechazadosCount;
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
          drawer: CoordinatorNavigationMenu(),
          appBar: AppBar(
            title: const Text('Inicio'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSectionTitle('Mis proyectos', Icons.work),
                const SizedBox(height: 10),
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _buildTotalProyectos(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const NewProject()));
                  },
                  child: Text('Crear proyecto nuevo'),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        // if (title == "Coordinadores") {
        //   Navigator.of(context).pushReplacement(MaterialPageRoute(
        //       builder: (context) => const CoordinadoresAdmin()));
        // } else {
        //   Navigator.of(context).pushReplacement(MaterialPageRoute(
        //       builder: (context) => const ProyectosAdminList()));
        // }
      },
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: Colors.black,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalProyectos() {
    return ExpansionTile(
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total de proyectos',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
            ),
            Text(
              proyectos.length.toString(),
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
      children: [
        _buildProyectosAceptados(),
        _buildProyectosEnEspera(),
        _buildProyectosRechazados(),
      ],
    );
  }

  Widget _buildProyectosAceptados() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.lightGreen[100],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Proyectos aceptados',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            '$proyectosAceptados',
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProyectosEnEspera() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.brown[100],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Proyectos en espera',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            '$proyectosEnEspera',
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProyectosRechazados() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.red[100],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Proyectos rechazados',
            style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.normal),
          ),
          Text(
            '$proyectosRechazados',
            style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
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
            Icons.dashboard,
            color: Colors.black45,
            size: 32,
          ),
          const SizedBox(width: 16),
          Text(
            'Panel de Coordinador',
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
