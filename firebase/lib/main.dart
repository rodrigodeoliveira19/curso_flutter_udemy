import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  //_obterDados();
  _autenticacao();
  runApp(const MyApp());
}

_obterDados() async{
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

  //Get All - Pode aplicar filtros após a chamada de collection
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

  //Aplicando filtros - codigo Professor curso
  // uerySnapshot querySnapshot = await db.collection("usuarios")
  // //.where("nome", isEqualTo: "jamilton")
  // //.where("idade", isEqualTo: 31)
  //     .where("idade", isGreaterThan: 15)//< menor, > maior, >= maior ou igual, <= menor ou igual
  // //.where("idade", isLessThan: 30)
  // //descendente (do maior para o menor) ascendente (do menor para o maior)
  //     .orderBy("idade", descending: true )
  //     .orderBy("nome", descending: false )
  //     .limit(1)
  //     .getDocuments();
  //
  // for( DocumentSnapshot item in querySnapshot.documents ){
  //   var dados = item.data;
  //   print("filtro nome: ${dados["nome"]} idade: ${dados["idade"]}");
  // }

  print('Executei');
}

_autenticacao() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseAuth auth = FirebaseAuth.instance;

  /* Criando usuário com e-mail e senha */
  String email = "jamilton@gmail.com";
  String senha = "123456";


  //Crie o usuário e permanece logado.
  /*auth.createUserWithEmailAndPassword(
      email: email,
      password: senha
  ).then((firebaseUser){
    print("novo usuario: sucesso!! e-mail: " + firebaseUser.toString() );
  }).catchError((erro){
    print("novo usuario: erro " + erro.toString() );
  });*/

  //Desloga o usuário
  //auth.signOut();

  //Loga o usuário
  auth.signInWithEmailAndPassword(
      email: email,
      password: senha
  ).then((firebaseUser){
    print("Logar usuario: sucesso!! e-mail: " + firebaseUser.toString() );
  }).catchError((erro){
    print("Logar usuario: erro " + erro.toString() );
  });

  User? usuarioAtual = await auth.currentUser;
  if( usuarioAtual != null ){//logado
    print("Usuario atual logado email: " + usuarioAtual.toString());
  }else{//deslogado
    print("Usuario atual está DESLOGADO!!");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
