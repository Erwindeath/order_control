import 'package:flutter/material.dart';

Widget showData(String dato){
   String prefix="";
  return Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(child: Text(prefix,style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold))),
        Center(child: Text(dato,style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16.0))),
      ],
    ),
  );
}

