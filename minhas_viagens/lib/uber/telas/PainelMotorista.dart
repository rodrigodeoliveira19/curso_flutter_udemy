import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class PainelMotorista extends StatefulWidget {
  const PainelMotorista({Key? key}) : super(key: key);

  @override
  State<PainelMotorista> createState() => _PainelMotoristaState();
}

class _PainelMotoristaState extends State<PainelMotorista> {

  List<String> itensMenu = [
    "Configurações", "Deslogar"
  ];

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

  @override
  Widget build(BuildContext context) {
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
      body: Container(),
    );
  }
}
