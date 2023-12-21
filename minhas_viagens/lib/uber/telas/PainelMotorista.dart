import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../util/StatusRequisicao.dart';
import '../util/UsuarioFirebase.dart';

class PainelMotorista extends StatefulWidget {
  const PainelMotorista({Key? key}) : super(key: key);

  @override
  State<PainelMotorista> createState() => _PainelMotoristaState();
}

class _PainelMotoristaState extends State<PainelMotorista> {

  List<String> itensMenu = [
    "Configurações", "Deslogar"
  ];
  final _streamController = StreamController<QuerySnapshot>.broadcast();
  FirebaseFirestore db = FirebaseFirestore.instance;


  _deslogarUsuario() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacementNamed(context, "/");
  }

  _escolhaMenuItem( String escolha ){
    switch( escolha ){
      case "Deslogar" :
        _deslogarUsuario();
        break;
      case "Configurações" :
        break;
    }
  }

   _adicionarListenerRequisicoes(){ //Stream<QuerySnapshot>

    final stream = db.collection("requisicoes")
        .where("status", isEqualTo: StatusRequisicao.AGUARDANDO )
        .snapshots();

    stream.listen((dados){
      _streamController.add( dados );
    });
  }

  _recuperarRequisicaoAtivaMotorista() async {
    User? user = await UsuarioFirebase.getUsuarioAtual();

    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("requisicao_ativa_motorista").doc(user?.uid).get();
    var dadosRequisicao;
    if(snapshot.data() != null)
     dadosRequisicao = snapshot.data() as Map;

    if(dadosRequisicao == null){
      _adicionarListenerRequisicoes();
    }else{
      /*Sera direcionado para tela de corrida sem opção de voltar*/
      String idRequisicao = dadosRequisicao["id_requisicao"];
      Navigator.pushReplacementNamed(context, "/corrida",
          arguments: idRequisicao);
    }

  }

  @override
  void initState() {
    super.initState();
    /* Recuéra a requisição ativa para verificar se o motorista está atendendo
    alguma requisição e envia ele para a tela de corrida
    * */
    _recuperarRequisicaoAtivaMotorista();
  }

  @override
  Widget build(BuildContext context) {

    var mensagemCarregando = Center(
      child: Column(
        children: <Widget>[
          Text("Carregando requisições"),
          CircularProgressIndicator()
        ],
      ),
    );

    var mensagemNaoTemDados = Center(
      child: Text(
        "Você não tem nenhuma requisição :( ",
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Painel motorista"),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            itemBuilder: (context){

              return itensMenu.map((String item){

                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );

              }).toList();

            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _streamController.stream,
        builder: (context, snapshot){
          switch( snapshot.connectionState ){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return mensagemCarregando;
              break;
            case ConnectionState.active:
            case ConnectionState.done:

              if( snapshot.hasError ){
                return Text("Erro ao carregar os dados!");
              }else {

                if(snapshot.hasData){
                  QuerySnapshot<Object?>? querySnapshot = snapshot.data;
                  if( querySnapshot?.docs.length == 0 ){
                    return mensagemNaoTemDados;
                  }else{

                    return ListView.separated(
                        itemCount: querySnapshot!.docs.length,
                        separatorBuilder: (context, indice) => Divider(
                          height: 2,
                          color: Colors.grey,
                        ),
                        itemBuilder: (context, indice){

                          List<DocumentSnapshot> requisicoes = querySnapshot.docs.toList();
                          DocumentSnapshot item = requisicoes[ indice ];

                          String idRequisicao = item["id"];
                          String nomePassageiro = item["passageiro"]["nome"];
                          String rua = item["destino"]["rua"];
                          String numero = item["destino"]["numero"];

                          return ListTile(
                            title: Text( nomePassageiro ),
                            subtitle: Text("destino: $rua, $numero"),
                            onTap: () {
                              Navigator.pushNamed(context, "/corrida",
                                  arguments: idRequisicao);
                            },
                          );

                        }
                    );

                  }
                }

              }
              break;
          };
          return Text("Erro ao carregar Stream de dados os dados!");
        },
      ),
    );
  }
}
