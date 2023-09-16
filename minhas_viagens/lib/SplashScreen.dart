import 'dart:async';

import 'package:flutter/material.dart';
import 'package:minhas_viagens/Home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    /*Após 5 segundo de carregamento da SplashScreen
    Chame a Home.
    * */
    Timer(Duration(seconds: 5), (){
      Navigator.pushReplacement(context, 
          MaterialPageRoute(builder: (_)=> Home())
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.deepOrange,
        padding: EdgeInsets.all(60),
        child: Center(
          child: Image.asset("imagens/logo.png"),
        ),
      ),
    );
  }
}
