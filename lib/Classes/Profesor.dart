class Profesor {
  String name;
  String surname;
  String nif;
  String phone;
  String email;

  Profesor(
      {required this.name,
      required this.surname,
      required this.nif,
      required this.phone,
      required this.email});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'surname': surname,
      'nif': nif,
      'phone': phone,
      'email': email
    };
  }

  static Profesor fromMap(Map<String, dynamic> map) {
    return Profesor(
        name: map['name'],
        surname: map['surname'],
        nif: map['nif'],
        phone: map['phone'],
        email: map['email']);
  }
}
