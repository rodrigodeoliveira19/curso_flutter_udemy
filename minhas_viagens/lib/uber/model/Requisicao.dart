import 'package:minhas_viagens/uber/model/Usuario.dart';

import 'Destino.dart';

class Requisicao{

  late String _id;
  late String _status;
  late Usuario _passageiro;
  late Usuario _motorista;
  late Destino destino;

  Map<String, dynamic> toMap(){

    Map<String, dynamic> dadosPassageiro = {
      "nome" : this.passageiro.nome,
      "email" : this.passageiro.email,
      "tipoUsuario" : this.passageiro.tipoUsuario,
      "idUsuario" : this.passageiro.idUsuario,
    };

    Map<String, dynamic> dadosDestino = {
      "rua" : this.destino.rua,
      "numero" : this.destino.numero,
      "bairro" : this.destino.bairro,
      "cep" : this.destino.cep,
      "latitude" : this.destino.latitude,
      "longitude" : this.destino.longitude,
    };

    Map<String, dynamic> dadosRequisicao = {
      "id" : this.id,
      "status" : this.status,
      "passageiro" : dadosPassageiro,
      "motorista" : null,
      "destino" : dadosDestino,
    };

    return dadosRequisicao;

  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get status => _status;

  set status(String value) {
    _status = value;
  }

  Usuario get passageiro => _passageiro;

  set passageiro(Usuario value) {
    _passageiro = value;
  }

  Usuario get motorista => _motorista;

  set motorista(Usuario value) {
    _motorista = value;
  }
}