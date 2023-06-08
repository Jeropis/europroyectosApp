import 'Proyecto.dart';

class Usuario {
  String id;
  String name;
  String surname;
  String email;
  String country;
  String password;
  bool isAdmin = false;
  List<Proyecto> proyectos;
  String phone;
  String token;

  Usuario(
      {required this.id,
      required this.name,
      required this.surname,
      required this.email,
      required this.country,
      required this.password,
      required this.isAdmin,
      required this.proyectos,
      required this.phone,
      required this.token});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'surname': surname,
      'email': email,
      'country': country,
      'password': password,
      'isadmin': isAdmin,
      'proyectos': proyectos,
      'phone': phone,
      'token': token
    };
  }

  static Usuario fromMap(
      Map<String, dynamic> map, String id, List<Proyecto> proyectos) {
    return Usuario(
        id: id,
        name: map['name'],
        surname: map['surname'],
        email: map['email'],
        country: map['country'],
        password: map['password'],
        isAdmin: map['isadmin'],
        proyectos: proyectos,
        phone: map['phone'],
        token: map['token']);
  }
}
