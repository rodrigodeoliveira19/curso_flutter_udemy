import 'package:flutter/material.dart';

class EntradaSwitch extends StatefulWidget {
  const EntradaSwitch({Key? key}) : super(key: key);

  @override
  State<EntradaSwitch> createState() => _EntradaSwitchState();
}

class _EntradaSwitchState extends State<EntradaSwitch> {

  bool _escolhaUsuario = false;
  bool _escolhaConfiguracoes = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Entrada de dados"),
      ),
      body: Container(
        child: Column(
          children: [

            SwitchListTile(
                title: Text("Receber notificações?"),
                value: _escolhaUsuario,
                onChanged: (bool valor) {
                  setState(() {
                    _escolhaUsuario = valor;
                  });
                }),
            SwitchListTile(
                title: Text("Atualizar imagem?"),
                value: _escolhaConfiguracoes,
                onChanged: (bool valor) {
                  setState(() {
                    _escolhaConfiguracoes = valor;
                  });
                }),

            ElevatedButton(
              onPressed: () {
                print("Valor Switch Receber notificações: " + _escolhaUsuario.toString());
              },
              child: Text(
                "Obter valor botão",
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            )

            //Row
            // Switch(
            //     value: _escolhaUsuario,
            //     onChanged: (bool valor) {
            //       setState(() {
            //         _escolhaUsuario = valor;
            //       });
            //     }),
            // Text("Receber notificações?")
          ],
        ),
      ),
    );
  }
}
