import 'package:flutter/material.dart';
import 'package:youtube/telas/EmAlta.dart';
import 'package:youtube/telas/Inicio.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _indiceItemAtual = 0;

  @override
  Widget build(BuildContext context) {

    List<Widget> telas = [
      Inicio(),
      EmAlta(),
    ];

    return Scaffold(
      appBar: AppBar(
        //Cor para o AppBar
        backgroundColor: Colors.white,
        //Define um padrão de cores para os incones.
        iconTheme: IconThemeData(
          color: Colors.grey,
          opacity:0.8
        ),
        title: Image.asset("imagens/youtube.png",width: 98,height: 22),
        actions: [
          IconButton(onPressed: (){print("Icons.videocam");}, icon: Icon(Icons.videocam)),
          IconButton(onPressed: (){print("Icons.search");}, icon: Icon(Icons.search)),
          IconButton(onPressed: (){print("Icons.account_circle");}, icon: Icon(Icons.account_circle)),
        ],
      ),
      body: telas[_indiceItemAtual],
      bottomNavigationBar: BottomNavigationBar(
        // BottomNavigationBar - Dois tipos fixed e shifting
        type: BottomNavigationBarType.fixed,
        // Item selecionado
        currentIndex: _indiceItemAtual,
        onTap: (indice){
          setState(() {
            _indiceItemAtual = indice;
          });
        },
        items: [
          BottomNavigationBarItem(label: "Inicio", icon: Icon(Icons.home)),
          BottomNavigationBarItem(label: "Em alta", icon: Icon(Icons.whatshot)),
        ],
      ),
    );
  }
}
