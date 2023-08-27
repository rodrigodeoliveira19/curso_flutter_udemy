import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async{
  print('Antes WidgetsFlutterBinding');
  //Inicializar Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  print('Apos WidgetsFlutterBinding');

  FirebaseFirestore db = FirebaseFirestore.instance;
  print('Peguei a instancia de DB');

  //Insere e sobrescreve - doc representa o id na collection
  /*
      db.collection("usuarios")
      .doc("pontuacao_2")
      .set({"Rodrigo": "300"});*/

  //Adiciona com identificador automaticamente
  DocumentReference reference = await db.collection("noticias")
  .add(
      {
        "titulo": "Titulo Rodrigo",
        "ano": 2023
      }
  );
  print('Executei');
  print("Result: "+reference.id);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
