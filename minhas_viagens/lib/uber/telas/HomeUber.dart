import 'package:flutter/material.dart';
import 'package:minhas_viagens/uber/telas/Cadastro.dart';

class HomeUber extends StatefulWidget {
  const HomeUber({Key? key}) : super(key: key);

  @override
  State<HomeUber> createState() => _HomeUberState();
}

class _HomeUberState extends State<HomeUber> {

  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();

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
                      onPressed:(){
                      },
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Cadastro())
                        ); 
                      },
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
