import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _textoSalvo = "Nada Savo";
  TextEditingController _controllerCampo = TextEditingController();

  _salvar() async{
    String valorDigitado = _controllerCampo.text;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("key_user_text", valorDigitado);

    print("Valor Salvo: ${valorDigitado}");
  }
  _recuperar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _textoSalvo =  prefs.getString("key_user_text")! ?? "Sem valor";
    });
    print("Recuperar: ${_textoSalvo}");
  }
  _remover() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("key_user_text");
    print("Remoção: ${_textoSalvo}");

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manipulação de dados"),
      ),
      body: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Text(_textoSalvo),
            TextField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                label: Text("Digite algo"),
              ),
              controller: _controllerCampo,
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _salvar();
                  },
                  child: Text(
                    "Salvar",
                    style: TextStyle(fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _recuperar();
                  },
                  child: Text(
                    "Recuperar",
                    style: TextStyle(fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _remover();
                  },
                  child: Text(
                    "Remover",
                    style: TextStyle(fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
