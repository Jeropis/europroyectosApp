import 'package:cloud_firestore/cloud_firestore.dart';
import 'Alumno.dart';
import 'Profesor.dart';

class Proyecto {
  String id;
  String name;
  String descripcion;
  DateTime fechaInicio;
  DateTime fechaFin;
  String coordinador;
  double presupuesto;
  List<Map<String, dynamic>> alumnos;
  List<Map<String, dynamic>> profesores;
  String estado;
  String ciudad;
  Map<String, bool> pasosASeguir;

  Proyecto({
    required this.id,
    required this.name,
    required this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.coordinador,
    required this.presupuesto,
    required this.alumnos,
    required this.profesores,
    required this.estado,
    required this.ciudad,
    required this.pasosASeguir,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'descripcion': descripcion,
      'fechaInicio': Timestamp.fromDate(fechaInicio),
      'fechaFin': Timestamp.fromDate(fechaFin),
      'coordinador': coordinador,
      'presupuesto': presupuesto,
      'alumnos': alumnos,
      'profesores': profesores,
      'estado': estado,
      'ciudad': ciudad,
      'pasosASeguir': pasosASeguir,
    };
  }

  static Proyecto fromMap(Map<String, dynamic> map, String id) {
    return Proyecto(
      id: id,
      name: map['name'],
      descripcion: map['descripcion'],
      fechaInicio: (map['fechaInicio'] as Timestamp).toDate(),
      fechaFin: (map['fechaFin'] as Timestamp).toDate(),
      coordinador: map['coordinador'],
      presupuesto: map['presupuesto'] + 0.00,
      alumnos: List<Map<String, dynamic>>.from(map['alumnos']),
      profesores: List<Map<String, dynamic>>.from(map['profesores']),
      estado: map['estado'],
      ciudad: map['ciudad'],
      pasosASeguir: Map<String, bool>.from(map['pasosASeguir']),
    );
  }

  factory Proyecto.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Proyecto(
      id: data['id'],
      name: data['name'],
      descripcion: data['descripcion'],
      fechaInicio: (data['fechaInicio'] as Timestamp).toDate(),
      fechaFin: (data['fechaFin'] as Timestamp).toDate(),
      coordinador: data['coordinador'],
      presupuesto: data['presupuesto'] + 0.00,
      alumnos: List<Map<String, dynamic>>.from(data['alumnos'] ?? []),
      profesores: List<Map<String, dynamic>>.from(data['profesores'] ?? []),
      estado: data['estado'],
      ciudad: data['ciudad'],
      pasosASeguir: Map<String, bool>.from(data['pasosASeguir'] ?? {}),
    );
  }
}
