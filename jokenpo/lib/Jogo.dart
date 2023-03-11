import 'package:flutter/material.dart';

class Jogo extends StatefulWidget {
  const Jogo({Key? key}) : super(key: key);

  @override
  State<Jogo> createState() => _JogoState();
}

class _JogoState extends State<Jogo> {
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
          //Classe responsável por detectar toques na tela
          GestureDetector(
          /** Pode usar mais de uma função
           * onTap - Um clique na imagem
           * onDoubleTap - Dois cliques na imagem.
           */
          onTap: (){print("Cliqeyeb   dfdfdffdfd");},
            child: Image.asset("imagens/padrao.png"),
          ),
          Padding(
            padding: EdgeInsets.only(top: 32,bottom: 16),
            child: Text(
              "Escolha uma opção abaixo",
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
               Image.asset("imagens/pedra.png"),
               Image.asset("imagens/papel.png"),
               Image.asset("imagens/tesoura.png"),
             ],
           ),
         ),
        ],
      ),
    );
  }
}
