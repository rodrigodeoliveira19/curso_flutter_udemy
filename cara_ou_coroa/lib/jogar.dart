import 'package:flutter/material.dart';

class Jogar extends StatefulWidget {
  const Jogar({Key? key}) : super(key: key);

  @override
  State<Jogar> createState() => _JogarState();
}

class _JogarState extends State<Jogar> {
  void _exibirResultado() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset("imagens/logo.png"),
            GestureDetector(
              onTap: _exibirResultado,
              child: Image.asset("imagens/botao_jogar.png"),
            ),
          ],
        ),
      ),
    );
  }
}
