import 'package:europroyectos_app/Widgets/NavigationMenu.dart';
import 'package:europroyectos_app/pages/AdminHomePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

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
          appBar: AppBar(
            title: const Text("Inicio"),
            backgroundColor: Colors.blue.shade400,
          ),
          drawer: const NavigationMenu(),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(
                      right: 20, left: 20, bottom: 20, top: 20),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(138, 3, 168, 244),
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                  child: Column(
                    children: [
                      const Padding(padding: EdgeInsets.only(top: 10.0)),
                      const Text(
                        "Total de proyectos",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 25),
                      ),
                      GestureDetector(
                          onTap: () {
                            Fluttertoast.showToast(
                              msg: "Has pulsado 'aceptados'.",
                              toastLength: Toast.LENGTH_SHORT,
                            );

                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AdminHomePage()));
                          },
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            height: MediaQuery.of(context).size.height / 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.lightGreen,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(100.0)),
                                border: Border.all(
                                    color:
                                        const Color.fromRGBO(139, 250, 60, 1),
                                    width: 2)),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _buildHomeContainers(
                                "Aceptados",
                                "10",
                                context,
                              ),
                            ),
                          )),
                      GestureDetector(
                          onTap: () {
                            Fluttertoast.showToast(
                              msg: "Has pulsado 'en espera'.",
                              toastLength: Toast.LENGTH_SHORT,
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            height: MediaQuery.of(context).size.height / 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 230, 209, 133),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(100.0)),
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 230, 250, 200),
                                    width: 2)),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _buildHomeContainers(
                                "En espera",
                                "5",
                                context,
                              ),
                            ),
                          )),
                      GestureDetector(
                          onTap: () {
                            Fluttertoast.showToast(
                              msg: "Has pulsado 'rechazados'.",
                              toastLength: Toast.LENGTH_SHORT,
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            height: MediaQuery.of(context).size.height / 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 242, 115, 106),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(100.0)),
                                border: Border.all(
                                    color:
                                        const Color.fromARGB(255, 242, 90, 106),
                                    width: 2)),
                            alignment: Alignment.centerLeft,
                            child: _buildHomeContainers(
                              "Rechazados",
                              "3",
                              context,
                            ),
                          ))
                    ],
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(
                        right: 20, left: 20, bottom: 20, top: 10),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(138, 3, 168, 244),
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                    child: Column(
                      children: [
                        const Padding(padding: EdgeInsets.only(top: 10.0)),
                        const Text(
                          "Total de coordinadores",
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 25),
                        ),
                        GestureDetector(
                            onTap: () {
                              Fluttertoast.showToast(
                                msg: "Has pulsado 'coordinadores'.",
                                toastLength: Toast.LENGTH_SHORT,
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              height: MediaQuery.of(context).size.height / 10,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 32, 247, 179),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(25.0)),
                                  border: Border.all(
                                      color: const Color.fromARGB(
                                          255, 32, 200, 179),
                                      width: 2)),
                              alignment: Alignment.center,
                              child: const Text(
                                //Quitar const al meter el contador de coordinadores de base de datos
                                "4",
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w300,
                                    fontSize: 30),
                              ),
                            ))
                      ],
                    ))
              ],
            ),
          )));

  Widget _buildHomeContainers(
    String title,
    String count,
    BuildContext context,
  ) {
    return Container(
      height: MediaQuery.of(context).size.height / 8,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            count,
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}
