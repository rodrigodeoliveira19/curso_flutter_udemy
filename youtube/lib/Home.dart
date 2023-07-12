import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
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
      body: Container(),
    );
  }
}
