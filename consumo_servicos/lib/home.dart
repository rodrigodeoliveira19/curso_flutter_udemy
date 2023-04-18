import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String _resultado = "";
  TextEditingController _cepController = TextEditingController();

  void _recuperaCep() async{
    String cep = "01153000";
    String url = "https://viacep.com.br/ws/${_cepController.text}/json/";
    var uri = Uri.parse(url);

    http.Response response = await http.get(uri);
    Map<String, dynamic> responseMap = jsonDecode(response.body);
    print("reponse: "+responseMap.toString());
    print("logradouro: "+responseMap["logradouro"]);
    print("bairro: "+responseMap["bairro"]);
    print("localidade: "+responseMap["localidade"]);

    setState(() {
      _resultado  = "${responseMap["logradouro"]} - ${responseMap["bairro"]} - ${responseMap["localidade"]}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Consumo de serviço web"),
      ),
      body: Container(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Digite o cep: xxxxxxxx"),
              style: TextStyle(fontSize: 20),
              controller: _cepController,
            ),
            ElevatedButton(
              onPressed: _recuperaCep,
              child: Text(
                "Recuperar CEP: ",
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
            Text(_resultado),
          ],
        ),
      ),
    );
  }
}
