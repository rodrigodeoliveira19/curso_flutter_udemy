import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Future<Map> _recuperarPreco() async {
    String url = "https://blockchain.info/ticker";
    var uri = Uri.parse(url);

    http.Response response = await http.get(uri);
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map>(
        future: _recuperarPreco(),
        //snapshot - permite acesso aos dados retornados em _recuperarPreco.
        builder: (context, snapshot) {

          String resultado;
          switch( snapshot.connectionState ){
            case ConnectionState.none :
            case ConnectionState.waiting :
              print("conexao waiting");
              resultado = "Carregando...";
              break;
            case ConnectionState.active :
            case ConnectionState.done :
              print("conexao done");
              if( snapshot.hasError ){
                resultado = "Erro ao carregar os dados.";
              }else {

                double valor = snapshot.data!["BRL"]["buy"];
                resultado = "Preço do bitcoin: ${valor.toString()} ";

              }
              break;
          }

          return Center(
            child: Text( resultado ),
          );
        }
    );
  }
}
