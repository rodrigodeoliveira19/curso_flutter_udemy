import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minhas_viagens/uber/model/Usuario.dart';

class UsuarioFirebase{

  //Retorna o usuario autenticado
  static Future<User?> getUsuarioAtual() async{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    FirebaseAuth auth = FirebaseAuth.instance;
    return auth.currentUser;
  }

  static Future<Usuario> getUsuarioLogado() async{
    User? user = await getUsuarioAtual();
    if(user != null){
      String idUsuario = user.uid;

      FirebaseFirestore db = FirebaseFirestore.instance;

      //Get One
      DocumentSnapshot snapshot =
          await db.collection("usuarios").doc(idUsuario).get();
      var dados = snapshot.data() as Map;
      Usuario usuario = Usuario();
      usuario.tipoUsuario = dados["tipoUsuario"];
      usuario.nome = dados["nome"];
      usuario.email = dados["email"];
      usuario.idUsuario = idUsuario;

      return usuario;
    }

    throw "Não foi possível obter o usuário";
  }

  static atualizarDadosLocalizacao(
      String idRequisicao, double lat, double lon) async {
    Usuario usuario = await getUsuarioLogado();
    usuario.latitude = lat;
    usuario.longitude = lon; 

    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("requisicoes")
    .doc(idRequisicao)
    .update({
      "motorista": usuario.toMap()
    });
  }
}