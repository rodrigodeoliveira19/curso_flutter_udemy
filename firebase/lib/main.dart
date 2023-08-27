import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
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
  /*DocumentReference reference = await db.collection("noticias")
  .add(
      {
        "titulo": "Titulo Rodrigo",
        "ano": 2023
      }
  );

  print("Result: "+reference.id);
  */

  //Deleta
  //db.collection("usuarios").doc("pontuacao").delete();

  //Get One
  // DocumentSnapshot snapshot =
  //     await db.collection("usuarios").doc("pontuacao_2").get();
  // print('Dados: ${snapshot.data()}');
  // var dados = snapshot.data() as Map;
  // print("Valor : "+dados['Rodrigo']);

  //Get All
  // QuerySnapshot querySnapshot =
  // await db.collection("noticias").get();
  //
  // for(QueryDocumentSnapshot item in querySnapshot.docs){
  //   var dados = item.data() as Map;
  //   print("item: "+dados['titulo'] );
  // }

  //Get all Listen - Fica escutando caso houver mudanças no banco
  db.collection("usuarios").snapshots().listen((event) {
    for(QueryDocumentSnapshot item in event.docs){
      var dados = item.data() as Map;
      print("usuario: "+dados['Rodrigo'] );
    }
  });


  print('Executei');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
