import 'package:flutter/material.dart';
import 'package:minhas_viagens/uber/model/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({Key? key}) : super(key: key);

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  TextEditingController _controllerNome = TextEditingController(text: "Rodrigo");
  TextEditingController _controllerEmail = TextEditingController(text: "rodrigo@gmail.com");
  TextEditingController _controllerSenha = TextEditingController(text: "123456");
  bool _tipoUsuario = false;
  String _mensagemError = "";

  void _validarCampos(){
    String nome = _controllerNome.text;
    String email = _controllerEmail.text;
    String senha = _controllerSenha.text;

    if(nome.isNotEmpty){
      if(email.isNotEmpty && email.contains("@")){
        if(senha.isNotEmpty && senha.length > 5){
          Usuario usuario = Usuario();
          usuario.nome = nome;
          usuario.email = email;
          usuario.senha = senha;
          usuario.tipoUsuario = usuario.verificaTipoUsuario(_tipoUsuario);
          _cadastrarUsuario(usuario);

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

    }else{
      setState(() {
        _mensagemError = "Preencha o nome";
      });
    }
  }

  void _cadastrarUsuario(Usuario usuario) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;

    auth
        .createUserWithEmailAndPassword(
            email: usuario.email, password: usuario.senha)
        .then((firebaseUser) {
      print("novo usuario: sucesso!! e-mail: " + firebaseUser.toString());

      db
          .collection("usuarios")
          .doc(firebaseUser.user?.uid)
          .set(usuario.toMap());

      //redireciona para o painel, de acordo com o tipoUsuario
      switch( usuario.tipoUsuario ){
        case "motorista" :
          Navigator.pushNamedAndRemoveUntil(
              context,
              "/painel-motorista",
                  (_) => false
          );
          break;
        case "passageiro" :
          Navigator.pushNamedAndRemoveUntil(
              context,
              "/painel-passageiro",
                  (_) => false
          );
          break;
      }

    }).catchError((erro) {
      print("novo usuario: erro " + erro.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _controllerNome,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Nome completo",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16))),
                ),
                TextField(
                  controller: _controllerEmail,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "e-mail",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16))),
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
                          borderRadius: BorderRadius.circular(16))),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Text("Passageiro"),
                      Switch(value: _tipoUsuario, onChanged: (bool valor) {
                        setState(() {
                          _tipoUsuario = valor;
                        });
                      }),
                      Text("Motorista")
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 10),
                  child: ElevatedButton(
                    onPressed: _validarCampos,
                    child: Text(
                      "Cadastrar",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      "Erro",
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
