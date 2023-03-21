import 'package:flutter/material.dart';


class EntradaCheckBox extends StatefulWidget {
  const EntradaCheckBox({Key? key}) : super(key: key);

  @override
  State<EntradaCheckBox> createState() => _EntradaCheckBoxState();
}

class _EntradaCheckBoxState extends State<EntradaCheckBox> {
  bool _comidaBrasileira = false;
  bool _comidaMexicana = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Entrada de dados"),
      ),
      body: Container(
        child: Column(
          children: [

            //CheckboxListTile com lista de itens clicaveis.
            CheckboxListTile(
              title: Text("Comida Brasileira."),
              subtitle: Text("A melhor comida do mundo."),
              secondary: Icon(Icons.add_home_work_sharp),
              activeColor: Colors.brown,
              value: _comidaBrasileira,
              onChanged: (bool? valor) {
                setState(() {
                  _comidaBrasileira = valor!;
                });
              },
            ),
            CheckboxListTile(
              title: Text("Comida Mexica."),
              subtitle: Text("A segunda melhor comida do mundo."),
              secondary: Icon(Icons.add_home_work_sharp),
              activeColor: Colors.brown,
              value: _comidaMexicana,
              onChanged: (bool? valor) {
                setState(() {
                  _comidaMexicana = valor!;
                });
              },
            ),

            ElevatedButton(
              onPressed: (){
                print("Valor checkBox Comida Brasileira: "+ _comidaBrasileira.toString());
                print("Valor checkBox Comida Mexicana: "+ _comidaMexicana.toString());
              },
              child: Text(
                "Obter valor botão",
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            )
            // Text("Comida Brasileira."),
            // Checkbox(
            //     value: _estaSelecionado,
            //     onChanged: (bool? valor) {
            //       setState(() {
            //         _estaSelecionado = valor;
            //       });
            //     })
          ],
        ),
      ),
    );
  }
}
