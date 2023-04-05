import 'package:flutter/material.dart';

class TelaSecundaria extends StatefulWidget {
  String valor;

  TelaSecundaria(this.valor);

  @override
  State<TelaSecundaria> createState() => _TelaSecundariaState();
}

class _TelaSecundariaState extends State<TelaSecundaria> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tela Secundaria."),
        backgroundColor: Colors.black,
      ),
      body: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Text("Segunda Tela !!!. Valor passado: ${widget.valor}")
          ],
        ),
      ),
    );
  }
}
