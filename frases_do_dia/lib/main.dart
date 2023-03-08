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
    home: Scaffold(
      //Barra superior do App
      appBar: AppBar(
        title: Text("Instagram"),
        backgroundColor: Colors.green,
      ),
      //Corpo / Area Central
      body: Text("Add mensagem no body"),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green,
        child: Padding(
          padding: EdgeInsets.all(16),
        ),
      ),
    )
  ));
}
