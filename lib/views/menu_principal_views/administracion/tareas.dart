import 'package:flutter/material.dart';
import 'package:order_control/complements/colors.dart';
import 'package:order_control/views/menu_principal_views/administracion/administracion.dart';

class AdministrarTareas extends StatefulWidget {
  const AdministrarTareas({Key? key}) : super(key: key);

  @override
  State<AdministrarTareas> createState() => _AdministrarTareasState();
}

class _AdministrarTareasState extends State<AdministrarTareas> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: principal(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return const Administracion();
            }),
          );
        },
        tooltip: 'Agregar',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget principal() {
    return ListView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [cardFarmacia(), cardPlanificacion()],
          ),
        ),
      ],
    );
  }

  Widget cardFarmacia() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Farmacia",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colores.esquemaColor,
                    fontSize: 20)),
          ],
        ),
      ),
    );
  }

  Widget cardPlanificacion() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Planificacion",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colores.esquemaColor,
                    fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
