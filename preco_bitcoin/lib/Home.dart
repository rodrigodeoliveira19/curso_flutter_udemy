import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  String _preco = "";

  Future<void> _recuperarPreco() async {
    String url = "https://blockchain.info/ticker";
    var uri = Uri.parse(url);

    http.Response response = await http.get(uri);
    Map<String, dynamic> responseMap = jsonDecode(response.body);
    print("reponse: "+responseMap.toString());
    print("logradouro: "+responseMap["BRL"].toString());

    setState(() {
      _preco = responseMap["BRL"]["buy"].toString();
    });
    // print("bairro: "+responseMap["bairro"]);
    // print("localidade: "+responseMap["localidade"]);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("imagens/bitcoin.png"),
              Padding(
                padding: EdgeInsets.only(top: 30, bottom: 30),
                child: Text("R\$: ${_preco}",
                style: TextStyle(fontSize: 35),),
              ),
              ElevatedButton(
                onPressed: _recuperarPreco,
                child: Text(
                  "Recuperar Preço bitcoin: ",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.fromLTRB(30,15,30,15)
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
