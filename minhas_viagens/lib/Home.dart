import 'dart:async';

import 'package:flutter/material.dart';
import 'package:minhas_viagens/Mapa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final _controller = StreamController<QuerySnapshot>.broadcast();



  /*List _listaViagens = [
    "Cristo Redentor",
    "Grande Muralha da China",
    "Taj Mahal",
    "Machu Picchu",
    "Coliseu"
  ];*/

  _abrirMapa(){

  }

  _excluirViagem(){

  }

  _adicionarLocal(){
    Navigator.push(context,
        MaterialPageRoute( builder: (_)=> Mapa() )
    );
  }

  /*_adicionarListenerViagens() async {
    final stream = _db.collection("viagens")
        .snapshots();

    stream.listen((dados){
      _controller.add( dados );
    });
  }*/

   _obterViagensDoFirebase() async{
    //_initFirebase();
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    FirebaseFirestore _db = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot =
    await _db.collection("viagens").get();
    return querySnapshot.docs.toList();

  }

  @override
  void initState() {
    super.initState();
    //_initFirebase();
    //_adicionarListenerViagens();
  }

  _initFirebase() async{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas viagens"),
        backgroundColor: Colors.deepOrange,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {  _adicionarLocal(); },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepOrange,
      ),
      body:/*
      //Usando ListView.builder
      Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                itemCount: _listaViagens.length,
                itemBuilder: (context, index){

                  String titulo = _listaViagens[index];

                  return GestureDetector(
                    onTap: (){
                      _abrirMapa();
                    },
                    child: Card(
                      child: ListTile(
                        title: Text( titulo ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            GestureDetector(
                              onTap: (){
                                _excluirViagem();
                              },
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );

                }
            ),
          )
        ],
      ),*/

      StreamBuilder<QuerySnapshot>(
          stream: _controller.stream,
          builder: (context, snapshot){
            switch( snapshot.connectionState ){
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
              case ConnectionState.done:

              List<QueryDocumentSnapshot> viagens = _obterViagensDoFirebase()
              as List<QueryDocumentSnapshot<Object?>>;

                return Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                          itemCount: viagens.length,
                          itemBuilder: (context, index){

                            DocumentSnapshot item = viagens[index];
                            String titulo = item["titulo"];
                            String idViagem = item.id;

                            return GestureDetector(
                              onTap: (){
                                _abrirMapa(  );
                              },
                              child: Card(
                                child: ListTile(
                                  title: Text( titulo ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: (){
                                          _excluirViagem(  );
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Icon(
                                            Icons.remove_circle,
                                            color: Colors.red,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );

                          }
                      ),
                    )
                  ],
                );

                break;
            }
          }
      ),
    );
  }
}
