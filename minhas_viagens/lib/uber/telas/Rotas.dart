import 'package:flutter/material.dart';
import 'package:minhas_viagens/uber/telas/Cadastro.dart';
import 'package:minhas_viagens/uber/telas/Corrida.dart';
import 'package:minhas_viagens/uber/telas/HomeUber.dart';
import 'package:minhas_viagens/uber/telas/PainelMotorista.dart';
import 'package:minhas_viagens/uber/telas/PainelPassageiro.dart';

class Rotas{

  static Route<dynamic> gerarRotas(RouteSettings settings){

    final args = settings.arguments;

    switch(settings.name){
      case "/":
        return MaterialPageRoute(builder: (_) => HomeUber());
      case "/cadastro":
        return MaterialPageRoute(builder: (_) => Cadastro());
      case "/painel-passageiro":
        return MaterialPageRoute(builder: (_) => PainelPassageiro());
      case "/painel-motorista":
        return MaterialPageRoute(builder: (_) => PainelMotorista());
      case "/corrida":
        return MaterialPageRoute(builder: (_) => Corrida(
          args as String
        ));
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