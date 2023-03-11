import 'dart:math';

import 'package:flutter/material.dart';
import 'main.dart';

class Jogo extends StatefulWidget {
  const Jogo({Key? key}) : super(key: key);

  @override
  State<Jogo> createState() => _JogoState();
}

class _JogoState extends State<Jogo> {
  
  var _imagemApp = AssetImage("imagens/padrao.png");
  var _mensagem = "Escolha uma opção abaixo";

  void _opcaoSelecionada(String escolhaUsuario){
    var opcoes =["pedra","papel","tesoura"];
    var index = Random().nextInt(opcoes.length);
    var escolhaApp = opcoes[index];
    _setImagemEscolhaApp(escolhaApp);
    _validarGanhador(escolhaUsuario, escolhaApp);
  }

  void _setImagemEscolhaApp(String opcao){
    setState(() {
      this._imagemApp = AssetImage("imagens/$opcao"+".png");
    });
  }

  void _validarGanhador(String escolhaUsuario, String escolhaApp){
    //Validação do ganhador
    //Usuario Ganhador
    if(
    (escolhaUsuario == "pedra" && escolhaApp == "tesoura") ||
        (escolhaUsuario == "tesoura" && escolhaApp == "papel") ||
        (escolhaUsuario == "papel" && escolhaApp == "pedra")
    ){
      setState(() {
        this._mensagem = "Parabéns!!! Você ganhou :)";
      });
      //App Ganhador
    }else if(
    (escolhaApp == "pedra" && escolhaUsuario == "tesoura") ||
        (escolhaApp == "tesoura" && escolhaUsuario == "papel") ||
        (escolhaApp == "papel" && escolhaUsuario == "pedra")
    ){
      setState(() {
        this._mensagem = "Você perdeu :(";
      });
    }else{
      setState(() {
        this._mensagem = "Empatamos ;)";
      });
    }
  }
      
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("JokenPo"),
      ),
      body: Column(
        //Centralizou a coluna e os objetos da coluna
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
              padding: EdgeInsets.only(top: 32,bottom: 16),
              child: Text(
                "Escolha do App",
                textAlign: TextAlign.center,
                //formatação
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),) ,
          ),
          Image(image: this._imagemApp),
          //Classe responsável por detectar toques na tela
          Padding(
            padding: EdgeInsets.only(top: 32,bottom: 16),
            child: Text(
              this._mensagem,
              textAlign: TextAlign.center,
              //formatação
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),) ,
          ),
         //SingleChildScrollView - Utilizado para solucionar o problema de renderflex-overflowed-by-pixels-erro
          /* poderia utilizar o mainAxisAlignment: MainAxisAlignment.center na Row e definir um height:100 na imagem
          * */
         SingleChildScrollView(
           scrollDirection: Axis.horizontal,
           child: Row(
             children: [
               GestureDetector(
                 /** Pode usar mais de uma função
                  * onTap - Um clique na imagem
                  * onDoubleTap - Dois cliques na imagem.
                  */
                 onTap: ()=> _opcaoSelecionada("pedra"),
                 child: Image.asset("imagens/pedra.png"),
               ),
               GestureDetector(
                 onTap: (){_opcaoSelecionada("papel");},
                 child: Image.asset("imagens/papel.png"),
               ),
               GestureDetector(
                 onTap: ()=> _opcaoSelecionada("tesoura"),
                 child: Image.asset("imagens/tesoura.png"),
               ),
             ],
           ),
         ),
        ],
      ),
    );
  }
}
