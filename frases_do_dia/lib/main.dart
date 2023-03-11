import 'package:flutter/material.dart';
import 'dart:math';


void main(){
  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  var _frases = [
    "Seja bem-vindo. Essa é uma das minhas várias versões.",
    "Estamos todos tentando aprender como viver. Vamos ser gentis. ✌🏻",
    "Não me siga porque eu nem eu sei para onde estou indo 😂",
    "Quando estiver em busca de mudança, mude.",
    "Aqui a realidade é sem filtros. 👀"
  ];

  var _fraseGerada = "Clique abaixo para gerar uma frase!";

  void _gerarFrase(){
    var numeroSorteado = Random().nextInt(_frases.length);

    setState(() {
      _fraseGerada = _frases[numeroSorteado];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //AppBar - Barra superior do App
      appBar: AppBar(
        title: Text("Frases do dia"),
        backgroundColor: Colors.green,
      ),
      //Container - Cria uma caixa para componentes - Ocupa o espaço do componente caso exista.
      body: Container(
        //Espaçamento dentro do container..
        padding: EdgeInsets.all(16),
        width: double.infinity, // Faz o container ocupar toda area disponivel
        child: Column(
          //Alinha os componentes dentro da coluna
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,//gerou espaço entre os componentes filhos
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("imagens/logo-frases-do-dia.png"), 
            Text(_fraseGerada,
            textAlign: TextAlign.justify,//Alinhamento do texto.
            style: TextStyle(//Estilo
              fontSize: 17,
              fontStyle: FontStyle.italic,
              color: Colors.black
            ),),
            ElevatedButton(onPressed: _gerarFrase,
                child: Text("Nova Frase"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,

              ),
            )
          ],
        ),
      ),
    );
  }
}
