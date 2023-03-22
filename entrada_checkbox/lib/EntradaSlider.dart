import 'package:flutter/material.dart';

class EntradaSlider extends StatefulWidget {
  const EntradaSlider({Key? key}) : super(key: key);

  @override
  State<EntradaSlider> createState() => _EntradaSliderState();
}

class _EntradaSliderState extends State<EntradaSlider> {
  double _valor = 4;
  String _label = "Valor selecionado";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Entrada de dados"),
        ),
        body: Container(
            child: Column(children: [
          Slider(
              value: _valor,
              min: 0,
              max: 10,
              label: _label,
              divisions: 10,
              activeColor: Colors.deepOrangeAccent,
              onChanged: (double newValue) {
                setState(() {
                  _valor = newValue;
                  _label = "Valor selecionado "+_valor.toString();
                });
              }),
          ElevatedButton(
            onPressed: () {
              print("Valor Switch Receber notificações: " +
                  _valor.toString());
            },
            child: Text(
              "Obter valor botão",
              style: TextStyle(fontSize: 20),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
          )
        ])));
  }
}
