import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  getBD() async{
    final caminhoBancoDados = await getDatabasesPath();
    final localBancoDados = join(caminhoBancoDados,"banco.db");

    var bd = await openDatabase(
        localBancoDados,
        version: 1,
        onCreate: (db, dbVersaoRecente){
          String sql = "CREATE TABLE usuarios (id INTEGER PRIMARY KEY AUTOINCREMENT, nome VARCHAR, idade INTEGER) ";
          db.execute(sql);
        }
    );

    return bd;
  }

  //Existe outras formas de manipular dados. Ver doc.
  _salvar() async {

    Database bd = await getBD();

    Map<String, dynamic> dadosUsuario = {
      "nome" : "Maria Silva",
      "idade" : 58
    };
    int id = await bd.insert("usuarios", dadosUsuario);
    print("Salvo: $id " );
  }

  _listarUsuarios() async{
    Database bd = await getBD();
    String sql = "SELECT * FROM usuarios";

    List usuarios = await bd.rawQuery(sql);
    for(var usuario in usuarios){
      print(
        "id: "+ usuario["id"].toString() +
          "nome: "+ usuario["nome"] +
          "idade: "+ usuario["idade"].toString()
      ) ;
    }
  }

  @override
  Widget build(BuildContext context) {

    _salvar();
    _listarUsuarios();

    return Container();
  }
}
