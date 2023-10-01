import 'package:flutter/material.dart';
import 'package:minhas_viagens/uber/telas/Cadastro.dart';
import 'package:minhas_viagens/uber/telas/HomeUber.dart';

class Rotas{

  static Route<dynamic> gerarRotas(RouteSettings settings){

    switch(settings.name){
      case "/":
        return MaterialPageRoute(builder: (_) => HomeUber());
      case "/cadastro":
        return MaterialPageRoute(builder: (_) => Cadastro());
      default:
        _errorRota();
    }
    throw "Página não encontrada";
  }

  static Route<dynamic> _errorRota(){
    return MaterialPageRoute(
        builder: (_){
          return Scaffold(
            appBar: AppBar(title: Text("Página não encontrada"),),
            body: Center(
              child: Text("Página não encontrada"),
            ),
          );
        }
    );
  }
}