import 'package:flutter/material.dart';
import 'package:order_control/complements/colors.dart';

// ignore: non_constant_identifier_names
Widget MenuAcciones({children, int itemPorLinea = 1}) {
  List<Widget> newChildren = [];

  int dividir = itemPorLinea;
  int factor = (dividir < children.length) ? dividir : children.length;
  int factorCrecimiento = (children.length / dividir).ceil();
  for (var i = 0; i < factorCrecimiento; i++) {
    List<Widget> botones = [];
    for (var child in children.sublist(0, factor)) {
      botones.add(child);
    }
    children.removeRange(0, factor);
    factor = (dividir < children.length) ? dividir : children.length;
    newChildren.add(LineaMenu(children: botones, itemPorLinea: itemPorLinea));
  }

  return Expanded(
    child: SingleChildScrollView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      child: Column(
        children: newChildren,
      ),
    ),
  );
}

// ignore: non_constant_identifier_names
Widget LineaMenu({children, itemPorLinea}) {
  var vacios = itemPorLinea - children.length;

  for (var i = 0; i < vacios; i++) {
    children.add(BotonVacio());
  }

  return Row(
    children: children,
  );
}

// ignore: non_constant_identifier_names
Widget Principal({children}) {
  return Row(children: [
    Expanded(
      child: Column(
        children: children,
      ),
    ),
  ]);
}

// ignore: non_constant_identifier_names
Widget BotonMenu({
  String? nombre,
  IconData icono = Icons.token,
  IconData? secondaryIcon, // Nuevo parámetro opcional
  callback,
  bool? habilitado,
  color,
}) {
  
  return Expanded(
    child: GestureDetector(
      onTap: habilitado! ? () => callback() : null,
      child: Card(
        color: habilitado ? null : Colors.grey[200],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                Stack(
                  children: [
                    Icon(icono, color: habilitado ? color : Colors.grey, size: 50),
                    if (secondaryIcon != null)
                      Positioned.directional(
                        textDirection: TextDirection.ltr,
                        end: 0,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 54.0),
                            child: Icon(
                              secondaryIcon,
                              size: 25.0,
                              color: Colores.esquemaColor, // Cambia esto al color que desees
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  nombre!,
                  style: TextStyle(
                    color: habilitado ? Colors.black : Colors.grey,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// ignore: non_constant_identifier_names
Widget BotonVacio() {
  return const Expanded(
    child: SizedBox.shrink(),
  );
}
