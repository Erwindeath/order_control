import 'package:flutter/material.dart';
import 'package:order_control/complements/colors.dart';

class AdministrarPlanificacion extends StatefulWidget {
  const AdministrarPlanificacion({Key? key}) : super(key: key);

  @override
  State<AdministrarPlanificacion> createState() =>
      _AdministrarPlanificacionState();
}

class _AdministrarPlanificacionState extends State<AdministrarPlanificacion> {
  int index = -1;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ExpansionPanelList(
          expansionCallback: (i, isOpen) {
            setState(() {
              if (index == i) {
                index = -1;
              } else {
                index = i;
              }
            });
          },
          animationDuration: const Duration(seconds: 1),
          dividerColor: Colores.esquemaColor,
          elevation: 4,
          children: [
            panel("Lunes", 0, "Farmacia # 45", "Descripcion"),
            panel("Martes", 1, "Farmacia # 45", "Descripcion"),
            panel("Miercoles", 2, "Farmacia # 45", "Descripcion"),
            panel("Jueves", 3, "Farmacia # 45", "Descripcion"),
            panel("Viernes", 4, "Farmacia # 45", "Descripcion")
          ],
        ),
      ),
    );
  }

  ExpansionPanel panel(
      String tituloPrincipal, int indice, String titulo, String subtitulo) {
    return ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return ListTile(
          title: Text(tituloPrincipal),
        );
      },
      canTapOnHeader: true,
      body: Column(
        children: [
          tarjeta(titulo, subtitulo),
          tarjeta(titulo, subtitulo),
        ],
      ),
      isExpanded: index == indice,
    );
  }

  Widget tarjeta(String titulo, String subtitulo) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*Image.network('https://images.unsplash.com/photo-1603899607191-e9425cdfdd7e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=435&q=80',
                width: double.infinity,
                height: 250,),
                const SizedBox(height: 10.0),*/
                Text(
                  titulo,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18.0),
                ),
                const SizedBox(height: 5.0),
                Text(
                  subtitulo,
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Botón'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
