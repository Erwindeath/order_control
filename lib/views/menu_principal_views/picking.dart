import 'package:flutter/material.dart';
import 'package:order_control/complements/colors.dart';

class Product {
  final String name;
  final String ubicacion;

  Product({required this.name, required this.ubicacion});
}

class Picking extends StatefulWidget {
  const Picking({Key? key}) : super(key: key);

  @override
  State<Picking> createState() => _PickingState();
}

class _PickingState extends State<Picking> {
  var prueba = "Farmacia San gregorio # 25";
  final List<Product> _products = [
    Product(name: 'MEDIAS TRAVEL NEGRO M', ubicacion: 'CON1-R1-S1-A2-U30'),
    Product(
        name: 'PURIGI ACEITE CORP X 50 ML0593', ubicacion: 'CON1-R1-S1-A2-U40'),
    Product(name: 'EUCERIN ANTIEDAD FP5X50ML', ubicacion: 'CON1-R1-S2-A1-U60'),
  ];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                prueba,
                style: const TextStyle(
                    color: Colors.white, fontSize: 15.0), //<-- SEE HERE
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Stack(
              children: [
                const Image(
                  width: double.infinity,
                  height: 225.0,
                  fit: BoxFit.cover,
                  image: NetworkImage(
                      "https://images.unsplash.com/photo-1553413077-190dd305871c?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=435&q=80"),
                ),
                Container(
                  margin: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      barra(500, 1000),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Transform.translate(
                offset: const Offset(0.0, -20.0),
                child: Container(
                  width: double.infinity,
                  height: 350.0,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Column(children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ubicacion(),
                            ),
                            Expanded(
                              flex: 1,
                              child: botonNotificar(),
                            ),
                          ],
                        ),
                        Expanded(
                            child: SingleChildScrollView(
                                child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Column(
                            children: [
                              card(),
                              cardSecundario(),
                            ],
                          ),
                        )))
                        /* Container(child: card()),
                        cardSecundario(),*/
                      ]),
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }

  void _nextProduct() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _products.length;
    });
  }
@override
  void initState() {
   
    super.initState();
  }
  @override
  void dispose() {
   
    super.dispose();
  }
  Widget botonNotificar() {
    return IconButton(
        tooltip: "Notificar",
        color: Colors.red,
        onPressed: () {},
        icon: const Icon(
          Icons.notifications,
        ));
  }

  Widget ubicacion() {
    return Row(
      children: [
        IconButton(
            color: Colores.esquemaColor,
            onPressed: () {},
            icon: const Icon(Icons.location_on_rounded)),
        const Text("CON1-R1-S1-A1-U1",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colores.esquemaColor)),
      ],
    );
  }

  Widget card() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(
                width: 1, color: Color.fromARGB(255, 230, 230, 230))),
      ),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(9.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                      width: 60,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const [
                            Icon(Icons.shopping_cart_rounded,
                                color: Colores.esquemaColor, size: 60),
                          ],
                        ),
                      )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Text("ESPUMA-AFEIT GILL P-NORMX155ML"),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text("GILLETE DEL ECUADOR"),
                    ],
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 13.0),
                    child: Text(
                      'Cantidad: 0/10',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  IconButton(
                      tooltip: "Saltar",
                      onPressed: () {
                        _nextProduct();
                      },
                      icon: const Icon(Icons.keyboard_double_arrow_right_sharp,
                          color: Colores.esquemaColor, size: 30)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget cardSecundario() {
    final product = _products[_currentIndex];
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(9.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          "Siguiente producto",
                          style: TextStyle(fontSize: 10.0),
                        ),
                      ],
                    ),
                    Text(product.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colores.esquemaColor)),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Colores.esquemaColor,
                        ),
                        Text(product.ubicacion),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
                const Icon(Icons.shopping_cart_rounded,
                    size: 20.0, color: Colores.esquemaColor)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget barra(int progreso, int total) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          LinearProgressIndicator(
            value: progreso / total,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 5),
          Text(
            '$progreso/$total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
