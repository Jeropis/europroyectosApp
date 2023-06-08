import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:europroyectos_app/pages/UserDetailsPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Classes/Usuario.dart';
import '../DAO/FirestoreDao.dart';
import '../Widgets/NavigationMenu.dart';
import 'NewCoor.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

enum Actions { delete, edit }

class CoordinadoresAdmin extends StatefulWidget {
  const CoordinadoresAdmin({Key? key});

  @override
  State<CoordinadoresAdmin> createState() => _CoordinadoresAdminState();
}

class _CoordinadoresAdminState extends State<CoordinadoresAdmin> {
  List<Usuario> usuarios = [];
  List<Usuario> usuariosFiltrados = [];
  bool isLoading = true;
  String searchTerm = "";

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    FirestoreDao dao = FirestoreDao();
    List<Usuario> usuarios = await dao.getUsers();
    setState(() {
      this.usuarios = usuarios;
      this.usuariosFiltrados = usuarios;
      isLoading = false;
    });
  }

  void _filtrarUsuarios() {
    setState(() {
      usuariosFiltrados = usuarios
          .where((usuario) =>
              usuario.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
              usuario.email.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    });
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
            ),
          ),
          backgroundColor: Colors.lightBlue,
        ),
        body: Stack(
          children: [
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (!isLoading)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchTerm = value;
                        });
                        _filtrarUsuarios();
                      },
                      decoration: const InputDecoration(
                        labelText: "Buscar",
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: usuariosFiltrados.length,
                          itemBuilder: (context, index) {
                            return Slidable(
                                startActionPane: ActionPane(
                                    motion: const StretchMotion(),
                                    children: [
                                      Container(
                                        child: SlidableAction(
                                          backgroundColor: Colors.red,
                                          icon: Icons.delete,
                                          label: 'Eliminar',
                                          onPressed: (context) =>
                                              _onDismissed(index, 'delete'),
                                        ),
                                      )
                                    ]),
                                endActionPane: ActionPane(
                                    motion: const BehindMotion(),
                                    children: [
                                      SlidableAction(
                                        backgroundColor: Colors.green,
                                        icon: Icons.edit,
                                        label: 'Editar',
                                        onPressed: (context) =>
                                            _onDismissed(index, 'edit'),
                                      )
                                    ]),
                                child: _buildUsuarioTile(
                                    usuariosFiltrados[index]));
                          }),
                    ),
                  ),
                ],
              ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.0, 0.5),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const NewCoor()),
                    );
                  },
                  icon: const Icon(Icons.co_present_outlined),
                  label: const Text(
                    "Registrar",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ));

  void _onDismissed(int index, String action) {
    if (action == 'delete') {
      final usuarioA = usuarios[index];
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
              '¿Estás seguro que quieres eliminar este coordinador?',
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
                  final usuarioA = usuarios[index];
                  final fd = FirestoreDao();
                  fd.deleteUser(usuarioA.email);
                  setState(() => usuarios.removeAt(index));
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      final usuarioA = usuarios[index];
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailsPage(user: usuarioA),
          ));
    }
  }

  Widget _buildUsuarioTile(Usuario usuario) => GestureDetector(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(10.0),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            title: Text(
              "${usuario.name} ${usuario.surname}",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              usuario.email,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.normal,
              ),
            ),
            leading: const Icon(CupertinoIcons.person_alt_circle),
          ),
        ),
      );
}
