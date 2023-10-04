import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:minhas_viagens/uber/telas/Cadastro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/Usuario.dart';

class HomeUber extends StatefulWidget {
  const HomeUber({Key? key}) : super(key: key);

  @override
  State<HomeUber> createState() => _HomeUberState();
}

class _HomeUberState extends State<HomeUber> {

  TextEditingController _controllerEmail = TextEditingController(text: "rodrigo@gmail.com" );
  TextEditingController _controllerSenha = TextEditingController(text: "123456");
  String _mensagemError = "";
  bool _carregando = false;

  void _validarCampos(){
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if(email.isNotEmpty && email.contains("@")){
      if(senha.isNotEmpty && senha.length > 5){
        Usuario usuario = Usuario();
        usuario.email = email;
        usuario.senha = senha;

        _logarUsuario(usuario);

      }else{
        setState(() {
          _mensagemError = "Preencha a senha";
        });
      }
    }else{
      setState(() {
        _mensagemError = "Preencha o e-mail";
      });
    }
  }

  _logarUsuario(Usuario usuario) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    FirebaseAuth auth = FirebaseAuth.instance;

    setState(() {
      _carregando = true;
    });

    //Loga o usuário
    auth
        .signInWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((firebaseUser) {
      print("Logar usuario: sucesso!! e-mail: " + firebaseUser.toString());

      _redirecionaPainelPorTipoUsuario(firebaseUser.user!.uid);
      
    }).catchError((erro) {
      print("Logar usuario: erro " + erro.toString());
      setState(() {
        _mensagemError = "Erro ao autenticar o usuário. "
            "Verifique os dados e tente novamente."; 
      });
    });
  }

  _redirecionaPainelPorTipoUsuario(String idUsuario) async{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;

    //Get One
    DocumentSnapshot snapshot =
        await db.collection("usuarios").doc( idUsuario ).get();
    print('Dados: ${snapshot.data()}');
    var usuario = snapshot.data() as Map;
    String tipoUsuario = usuario['tipoUsuario'];

    setState(() {
      _carregando = false;
    });

    //redireciona para o painel, de acordo com o tipoUsuario
    switch( tipoUsuario ){
      case "motorista" :
        Navigator.pushReplacementNamed(
            context,
            "/painel-motorista"
        );
        break;
      case "passageiro" :
        Navigator.pushReplacementNamed(
            context,
            "/painel-passageiro"
        );
        break;
    }
  }

  void _verificarUsuarioLogado() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    FirebaseAuth auth = FirebaseAuth.instance;

    User? usuarioAtual = await auth.currentUser;
    if( usuarioAtual != null ){
      String idUsuario = usuarioAtual.uid;
      _redirecionaPainelPorTipoUsuario(idUsuario);
    }
  }

  @override
  void initState() {
    super.initState();
    _verificarUsuarioLogado();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("imagens/uber/fundo.png"),
              fit: BoxFit.cover
            )
          ),
          padding: EdgeInsets.all(16),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 32),
                    child: Image.asset(
                    "imagens/uber/logo.png",
                    width: 200,
                    height: 150,
                  ),
                  ),
                  TextField(
                    controller: _controllerEmail,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "e-mail",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)
                      )
                    ),
                  ),
                  TextField(
                    controller: _controllerSenha,
                    obscureText: true,
                    // keyboardType: TextInputType.visiblePassword,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "Senha",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16)
                        )
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 10),
                    child: ElevatedButton(
                      onPressed: _validarCampos,
                      child: Text(
                        "Entrar",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    ),
                  ),
                  ),
                  Center(
                    child: GestureDetector(
                      child: Text(
                        "Não tem conta? cadastre-se!",
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: (){
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(builder: (context) => Cadastro())
                        // );
                        Navigator.pushNamed(context, "/cadastro");
                      },
                    ),
                  ),

                  _carregando ?
                      Center(child: CircularProgressIndicator(backgroundColor: Colors.white,),) :
                      Container(),

                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(
                        _mensagemError,
                        style: TextStyle(color: Colors.red, fontSize: 20),
                      ),
                    ),
                  )
              ],
              ),
            ),
          ),
        ),
    );
  }
}
