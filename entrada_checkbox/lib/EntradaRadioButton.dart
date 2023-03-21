import 'package:flutter/material.dart';


class EntradaRadioButton extends StatefulWidget {
  const EntradaRadioButton({Key? key}) : super(key: key);

  @override
  State<EntradaRadioButton> createState() => _EntradaRadioButtonState();
}

class _EntradaRadioButtonState extends State<EntradaRadioButton> {

  String _escolhaDoUsuario = "m";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Entrada de dados"),
      ),
      body: Container(
        child: Column(
          children: [

            //Estrutura de coluna
            RadioListTile(
                title: Text("Masculino"),
                value: "m",
                groupValue: _escolhaDoUsuario,
                onChanged: (String? escolha) {
                  setState(() {
                    _escolhaDoUsuario = escolha!;
                  });
                  print("Masculino: " + escolha!);
                }),
            RadioListTile(
                title: Text("Feminino"),
                value: "f",
                groupValue: _escolhaDoUsuario,
                onChanged: (String? escolha) {
                  setState(() {
                    _escolhaDoUsuario = escolha!;
                  });
                  print("Feminino: " + escolha!);
                }),

            ElevatedButton(
              onPressed: (){
                print("Valor radioButton: "+ _escolhaDoUsuario);
              },
              child: Text(
                "Obter valor botão",
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            )
            /*Estrutura de linha
            Text("Masculino"),
            Radio(
                value: "m",
                groupValue: _escolhaDoUsuario,
                onChanged: (String? escolha) {
                  setState(() {
                    _escolhaDoUsuario = escolha!;
                  });
                  print("Masculino: "+escolha!);
                }),
            Text("Masculino"),
            Radio(
                value: "f",
                groupValue: _escolhaDoUsuario,
                onChanged: (String? escolha) {
                  setState(() {
                    _escolhaDoUsuario = escolha!;
                  });
                  print("Feminino: "+escolha!);
                })
            */

          ],
        ),
      ),
    );
  }
}
