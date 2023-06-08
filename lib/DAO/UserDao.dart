// import 'package:cloud_firestore/cloud_firestore.dart';

// import '../Classes/Usuario.dart';

// class UserDao {
//   final CollectionReference usersCollection =
//       FirebaseFirestore.instance.collection('users');

//   // Método para obtener los datos del usuario por su correo electrónico
//   Future<Usuario> getUserByEmail(String? email) async {
//     final query = await usersCollection.where('email', isEqualTo: email).get();
//     if (query.docs.isNotEmpty) {
//       final data = query.docs.first.data() as Map<String, dynamic>;
//       return Usuario(
//         name: data['name'] as String,
//         surname: data['surname'] as String,
//         email: data['email'] as String,
//         country: data['country'] as String,
//         password: data['password'] as String,
//         isAdmin: data['isadmin'] as bool,
//       );
//     } else {
//       return Future.error(
//           'No se encontró un usuario con el correo electrónico proporcionado.');
//     }
//   }

//   // Método para agregar un nuevo usuario a la base de datos
//   Future<void> addUser(Usuario user) async {
//     await usersCollection.doc(user.email).set({
//       'name': user.name,
//       'surname': user.surname,
//       'email': user.email,
//       'country': user.country,
//       'password': user.password,
//       'isAdmin': user.isAdmin,
//     });
//   }

//   // Método para actualizar los datos del usuario en la base de datos
//   Future<void> updateUser(Usuario user) async {
//     await usersCollection.doc(user.email).update({
//       'name': user.name,
//       'surname': user.surname,
//       'country': user.country,
//       'password': user.password,
//       'isAdmin': user.isAdmin,
//     });
//   }

//   // Método para eliminar un usuario de la base de datos
//   Future<void> deleteUser(String email) async {
//     await usersCollection.doc(email).delete();
//   }
// }
