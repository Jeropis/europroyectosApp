import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:europroyectos_app/Classes/Proyecto.dart';
import 'package:europroyectos_app/Classes/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreDao {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Usuario> getUser(String userId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      List<Proyecto> projects = await getAllProjectsByUser(userId);
      return Usuario.fromMap(
          userDoc.data() as Map<String, dynamic>, userId, projects);
    } else {
      throw Exception("User not found");
    }
  }

  Future<List<Proyecto>> getAllProjectsByUser(String userId) async {
    List<Proyecto> projects = [];

    DocumentSnapshot userSnapshot =
        await _firestore.collection('users').doc(userId).get();
    if ((userSnapshot.data() as Map<String, dynamic>?)
            ?.containsKey('proyectos') ??
        false) {
      List<dynamic> projectsData = userSnapshot.get('proyectos') ?? [];

      for (var projectData in projectsData) {
        Proyecto project = Proyecto.fromMap(projectData, userSnapshot.id);
        projects.add(project);
      }
    }
    return projects;
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  Future<List<Proyecto>> getProyectosPorEstado(String estado) async {
    QuerySnapshot snapshot = await _firestore
        .collection('proyectos')
        .where('estado', isEqualTo: estado)
        .get();

    List<Proyecto> proyectos = [];
    snapshot.docs.forEach((doc) {
      proyectos
          .add(Proyecto.fromMap(doc.data() as Map<String, dynamic>, doc.id));
    });

    return proyectos;
  }

  Future<List<Usuario>> getUsersByIds(List<String> userIds) async {
    List<Usuario> users = [];
    for (String userId in userIds) {
      Usuario user = await getUser(userId);
      users.add(user);
    }
    return users;
  }

  Future<void> addOrUpdateUser(Usuario user) async {
    Map<String, dynamic> userMap = user.toMap();
    await _firestore.collection('users').doc(user.id).set(userMap);
  }

  Future<void> addOrUpdateProjects(
      String userId, List<Proyecto> projects) async {
    final userRef = _firestore.collection('users').doc(userId);

    // Obtener los datos actuales del usuario
    final userDoc = await userRef.get();
    final userData = userDoc.data() ?? {};

    // Actualizar o agregar cada proyecto
    final List<Map<String, dynamic>> proyectosData =
        projects.map((project) => project.toMap()).toList();
    for (final projectData in proyectosData) {
      final projectId = projectData['name'];
      final projectIndex =
          userData['proyectos']?.indexWhere((p) => p['name'] == projectId);
      if (projectIndex! >= 0) {
        // Si el proyecto ya existe, actualizar sus datos
        userData['proyectos']?[projectIndex] = projectData;
      } else {
        // Si el proyecto no existe, agregarlo al final del array
        userData.putIfAbsent('proyectos', () => []).add(projectData);
      }
    }

    // Actualizar los datos del usuario en la base de datos
    await userRef.update({'proyectos': userData['proyectos']});
  }

  Future<void> deleteProject(String userId, String projectId) async {
    final userRef = _firestore.collection('users').doc(userId);

    // Obtener los datos actuales del usuario
    final userDoc = await userRef.get();
    final userData = userDoc.data() ?? {};

    // Verificar si existe el proyecto
    final proyectosData = userData['proyectos'] as List<dynamic>;
    final projectIndex = proyectosData.indexWhere((p) => p['name'] == projectId);
    if (projectIndex >= 0) {
      // Eliminar el proyecto del array
      proyectosData.removeAt(projectIndex);

      // Actualizar los datos del usuario en la base de datos
      await userRef.update({'proyectos': proyectosData});
    }
  }

  Future<List<Proyecto>> getAllProjects() async {
    FirestoreDao firestoreDao = FirestoreDao();
    List<Proyecto> allProjects = [];
    List<Usuario> users = await getUsers();
    for (Usuario user in users) {
      List<Proyecto> projects =
          await firestoreDao.getAllProjectsByUser(user.id);
      allProjects.addAll(projects);
    }
    return allProjects;
  }

  void actualizarTokenUser(String id, String token) {
         FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update({'token': token});
  }

  Future<List<Usuario>> getUsers() async {
    FirestoreDao firestoreDao = FirestoreDao();
    QuerySnapshot usersSnapshot =
        await firestoreDao._firestore.collection('users').get();
    List<Usuario> users = [];
    for (DocumentSnapshot userDoc in usersSnapshot.docs) {
      List<Proyecto> projects =
          await firestoreDao.getAllProjectsByUser(userDoc.id);
      Usuario user = Usuario.fromMap(
          userDoc.data() as Map<String, dynamic>, userDoc.id, projects);
      users.add(user);
    }
    return users;
  }
}
