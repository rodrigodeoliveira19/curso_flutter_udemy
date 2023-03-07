import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: "Frases do dia",
    //Atributo para widgets
    // home: Row(children: [
    //   Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit ",
    //     style: TextStyle(fontSize: 20),),
    //   Text("T2: ")
    // ],),
    home: Container(
      //color: Colors.white,
      decoration:
          BoxDecoration(border: Border.all(width: 3, color: Colors.cyan)),
      margin: EdgeInsets.only(top: 40),
      child: Image.asset(
        "imagens/uber_2.png",
        //Area ocupada.
        fit: BoxFit.fill,
      )
    ),
  ));
}
