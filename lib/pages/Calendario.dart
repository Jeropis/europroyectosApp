import 'package:europroyectos_app/DAO/FirestoreDao.dart';
import 'package:europroyectos_app/Widgets/NavigationMenu.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../Classes/Proyecto.dart';

class Calendario extends StatefulWidget {
  @override
  _CalendarioState createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  final List<DateTime> _projectDates =
      []; // lista para almacenar las fechas de los proyectos
  var _proyectos = FirestoreDao().getAllProjects();
  var camasGranada = 32;
  var camasMartos = 29;
  var camasCordoba = 26;
  var camasMalaga = 39;
  var _totalAlumnos = 0;
  var _totalProfesores = 0;
  List<String> _ciudades = ['Málaga', 'Cordoba', 'Martos', 'Granada'];
  int _ciudadSeleccionadaIndex = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getProjectsByStateCity();
  }

  void _getProjectDates() async {
    final fd = FirestoreDao();
    final proyectos = await fd.getAllProjects();
    List<DateTime> dates = [];
    for (var proyecto in proyectos) {
      var fI = DateTime.utc(proyecto.fechaInicio.year,
          proyecto.fechaInicio.month, proyecto.fechaInicio.day);
      var fF = DateTime.utc(proyecto.fechaFin.year, proyecto.fechaFin.month,
          proyecto.fechaFin.day);
      for (var i = fI.add(Duration(days: 1));
          i.isBefore(fF.add(Duration(days: 1)));
          i = i.add(Duration(days: 1))) {
        _projectDates.add(i);

      }
    }
  }

  Future<Proyecto> getProjectByDate(DateTime date) async {
    final fd = FirestoreDao();
    final proyectos = await fd.getAllProjects();
    return proyectos.firstWhere((proyecto) =>
        date.isAfter(proyecto.fechaInicio) &&
        date.isBefore(proyecto.fechaFin.add(Duration(days: 1))));
  }

  void getProjectsByStateCity() async {
    _totalAlumnos = 0;
    _isLoading=true;
    final fd = FirestoreDao();
    List<DateTime> dates = [];
    final proyectos = await fd.getAllProjects();
    List<Proyecto> listaAprobada = [];
    for (var project in proyectos) {
      if (project.estado == 'aprobado') {
        listaAprobada.add(project);
      }
    }
    switch (_ciudadSeleccionadaIndex) {
      case 0:
        bool hasProjectDates =
            false; // Variable para indicar si se encontraron fechas de proyectos
        int totalAlumnos = 0;
        int totalProfesores = 0;
        for (var project in listaAprobada) {
          if (project.ciudad == 'Málaga') {
            var fI = DateTime.utc(project.fechaInicio.year,
                project.fechaInicio.month, project.fechaInicio.day);
            var fF = DateTime.utc(project.fechaFin.year, project.fechaFin.month,
                project.fechaFin.day);
            for (var i = fI;
                i.isBefore(fF.add(Duration(days: 1)));
                i = i.add(Duration(days: 1))) {
              _projectDates.add(i);
              hasProjectDates = true;
              if (i.isAtSameMomentAs(_selectedDay!)) {
                totalAlumnos += project.alumnos.length;
                totalProfesores += project.profesores.length;
              }

            }
          }
        }

        setState(() {
          if (hasProjectDates && _projectDates.contains(_selectedDay)) {
            _totalAlumnos = totalAlumnos + totalProfesores;
          } else {
            _totalAlumnos = 0;
          }
        });
        _isLoading=false;
        break;
      case 1:
        bool hasProjectDates =
            false; // Variable para indicar si se encontraron fechas de proyectos
        int totalAlumnos = 0;
        int totalProfesores = 0;
        for (var project in listaAprobada) {
          if (project.ciudad == 'Cordoba') {
            var fI = DateTime.utc(project.fechaInicio.year,
                project.fechaInicio.month, project.fechaInicio.day);
            var fF = DateTime.utc(project.fechaFin.year, project.fechaFin.month,
                project.fechaFin.day);
            for (var i = fI;
                i.isBefore(fF.add(Duration(days: 1)));
                i = i.add(Duration(days: 1))) {
              _projectDates.add(i);
              hasProjectDates = true;
              if (i.isAtSameMomentAs(_selectedDay!)) {
                totalAlumnos += project.alumnos.length;
                totalProfesores += project.profesores.length;
              }

            }
          }
        }

        setState(() {
          if (hasProjectDates && _projectDates.contains(_selectedDay)) {
            _totalAlumnos = totalAlumnos + totalProfesores;
          } else {
            _totalAlumnos = 0;
          }
        });
        _isLoading=false;
        break;
      case 2:
        bool hasProjectDates =
            false; // Variable para indicar si se encontraron fechas de proyectos
        int totalAlumnos = 0;
        int totalProfesores = 0;
        for (var project in listaAprobada) {
          if (project.ciudad == 'Martos') {
            var fI = DateTime.utc(project.fechaInicio.year,
                project.fechaInicio.month, project.fechaInicio.day);
            var fF = DateTime.utc(project.fechaFin.year, project.fechaFin.month,
                project.fechaFin.day);
            for (var i = fI;
                i.isBefore(fF.add(Duration(days: 1)));
                i = i.add(Duration(days: 1))) {
              _projectDates.add(i);
              hasProjectDates = true;
              if (i.isAtSameMomentAs(_selectedDay!)) {
                totalAlumnos += project.alumnos.length;
                totalProfesores += project.profesores.length;
              }

            }
          }
        }

        setState(() {
          if (hasProjectDates && _projectDates.contains(_selectedDay)) {
            _totalAlumnos = totalAlumnos + totalProfesores;
          } else {
            _totalAlumnos = 0;
          }
        });
        _isLoading=false;
        break;
      case 3:
        bool hasProjectDates =
            false; // Variable para indicar si se encontraron fechas de proyectos
        int totalAlumnos = 0;
        int totalProfesores = 0;
        for (var project in listaAprobada) {
          if (project.ciudad == 'Granada') {
            var fI = DateTime.utc(project.fechaInicio.year,
                project.fechaInicio.month, project.fechaInicio.day);
            var fF = DateTime.utc(project.fechaFin.year, project.fechaFin.month,
                project.fechaFin.day);
            for (var i = fI;
                i.isBefore(fF.add(Duration(days: 1)));
                i = i.add(Duration(days: 1))) {
              _projectDates.add(i);
              hasProjectDates = true;
              if (i.isAtSameMomentAs(_selectedDay!)) {
                totalAlumnos += project.alumnos.length;
                totalProfesores += project.profesores.length;
              }

            }
          }
        }

        setState(() {
          if (hasProjectDates && _projectDates.contains(_selectedDay)) {
            _totalAlumnos = totalAlumnos + totalProfesores;
          } else {
            _totalAlumnos = 0;
          }
        });
        _isLoading=false;
        break;
    }
  }

  void _getProjectDates1() async {
    final fd = FirestoreDao();
    final proyectos = await fd.getAllProjects();
    List<DateTime> dates = [];
    int totalAlumnos = 0;
    int totalProfesores = 0;

    for (var proyecto in proyectos) {
      if (proyecto.ciudad == _ciudades[_ciudadSeleccionadaIndex]) {
        var fI = DateTime.utc(proyecto.fechaInicio.year,
            proyecto.fechaInicio.month, proyecto.fechaInicio.day);
        var fF = DateTime.utc(proyecto.fechaFin.year, proyecto.fechaFin.month,
            proyecto.fechaFin.day);
        for (var i = fI.add(Duration(days: 1));
            i.isBefore(fF.add(Duration(days: 1)));
            i = i.add(Duration(days: 1))) {
          dates.add(i);
        }
        setState(() {
          totalAlumnos += proyecto.alumnos.length;
          totalProfesores += proyecto.profesores.length;
        });
      }
    }

    setState(() {
      // _projectDates = dates;
      _totalAlumnos = totalAlumnos;
      _totalProfesores = totalProfesores;
    });
  }

  // Future<Proyecto> getProjectByDateAndCity(DateTime date, String city) async {
  //   final fd = FirestoreDao();
  //   final proyectos = await fd.getAllProjects();
  //   return proyectos.firstWhere((proyecto) =>
  //   date.isAfter(proyecto.fechaInicio) &&
  //       date.isBefore(proyecto.fechaFin.add(Duration(days: 1))) &&
  //       proyecto.ciudad == city);
  // }
  //TODO funcion para coger proyectos por fecha y ciudad
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
            title: Text('Calendario'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: _ciudades[_ciudadSeleccionadaIndex],
                          onChanged: (String? ciudadSeleccionada) {
                            setState(() {
                              _ciudadSeleccionadaIndex =
                                  _ciudades.indexOf(ciudadSeleccionada!);
                              _projectDates.clear();
                              _totalAlumnos = 0;
                                  getProjectsByStateCity();

                            });
                          },
                          items: _ciudades
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      Text(_ciudades[_ciudadSeleccionadaIndex])
                    ],
                  ),
                ),
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {

                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay =
                          focusedDay; // update `_focusedDay` here as well
                      getProjectsByStateCity();
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    markersAlignment: Alignment.bottomCenter,
                    markersMaxCount: 1,
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      // Verificar si la fecha está en la lista de fechas de proyectos
                      if (_projectDates.contains(date)) {
                        // Verificar si la fecha es igual al día seleccionado
                        if (isSameDay(date, _selectedDay)) {
                          return Icon(
                            Icons.radio_button_off_outlined,
                            color: getCamasLibres() <= 0 ? Colors.red : Colors.yellow,
                            size: 50.0,
                          );
                        } else {
                          return Icon(
                            Icons.radio_button_off_outlined,
                            color: Colors.blue[100],
                            size: 50.0,
                          );
                        }
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 22)),
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                  child: Column(
                    children: [
                      Padding(padding: EdgeInsets.all(10)),
                      buildTextContainer(
                          'Número total de camas: ${getCamasDisponibles()}'),
                      Padding(padding: EdgeInsets.all(10)),
                      buildTextContainer(
                          'Número de camas ocupadas: ${_totalAlumnos}'),
                      Padding(padding: EdgeInsets.all(10)),
                      buildTextContainer(
                          'Número total de camas libres: ${getCamasLibres()}'),
                      Padding(padding: EdgeInsets.all(10)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Container buildTextContainer(String text) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.5),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
          _isLoading ? Center(
            child: CircularProgressIndicator(),
          ):
          Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  int getCamasLibres() {
    int capacidadTotal = 0;

    // Asigna la capacidad total de camas según la ciudad seleccionada
    switch (_ciudadSeleccionadaIndex) {
      case 0: // Málaga
        capacidadTotal = camasMalaga;
        break;
      case 1: // Granada
        capacidadTotal = camasCordoba;
        break;
      case 2: // Martos
        capacidadTotal = camasMartos;
        break;
      case 3: // Córdoba
        capacidadTotal = camasGranada;
        break;
      default:
        capacidadTotal = 0;
    }

    int camasDisponibles = capacidadTotal - _totalAlumnos;
    return camasDisponibles >= 0 ? camasDisponibles : 0;
  }

  String getCamasDisponibles() {
    switch (_ciudadSeleccionadaIndex) {
      case 0:
        return camasMalaga.toString();
      case 1:
        return camasCordoba.toString();
      case 2:
        return camasMartos.toString();
      case 3:
        return camasGranada.toString();
      default:
        return '';
    }
  }
}
