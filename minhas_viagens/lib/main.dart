import 'package:flutter/material.dart';
import 'package:minhas_viagens/SplashScreen.dart';
import 'package:minhas_viagens/uber/telas/HomeUber.dart';



void main() {
  runApp(MaterialApp(
    /*Projeto minhas viagens
    title: "Minhas Viagens",
    home: SplashScreen(),
    */
    //Projeto Uber
    title: "Uber",
    home: HomeUber(),
    debugShowCheckedModeBanner: false,
  ));
}