import 'package:flutter/material.dart';
import 'package:order_control/views/menu_principal_views/perchador/notificaciones_pendientes_obligatorias.dart';
import 'package:order_control/views/menu_principal_views/perchador/notificaciones_pendientes_opcionales.dart';

class HomeNotificaciones extends StatefulWidget {
  const HomeNotificaciones({Key? key}) : super(key: key);

  @override
  State<HomeNotificaciones> createState() => _HomeNotificacionesState();
}

class _HomeNotificacionesState extends State<HomeNotificaciones> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: const Text("Novedades Pendientes"),
          bottom: const TabBar(
            unselectedLabelColor: Color(0xffB59498),
            labelColor: Colors.white,
            tabs: [
              Tab(
                icon: Icon(Icons.event_note),
                text: 'Obligatorias',
              ),
              Tab(
                icon: Icon(Icons.analytics),
                text: 'Opcionales',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            NotificacionesPendientes(),
            NotificacionesPendientesOpcionales(),
          ],
        ),
      ),
    );
  }
}
