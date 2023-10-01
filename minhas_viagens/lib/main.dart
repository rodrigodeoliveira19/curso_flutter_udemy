import 'package:flutter/material.dart';
import 'package:minhas_viagens/SplashScreen.dart';
import 'package:minhas_viagens/uber/telas/HomeUber.dart';
import 'package:minhas_viagens/uber/telas/Rotas.dart';

/*final ThemeData themaPadra = ThemeData(
  primaryColor: Color(0xff37474f),
  secondaryHeaderColor: Colors.red
);*/

void main() {
  runApp(MaterialApp(
    /*Projeto minhas viagens
    title: "Minhas Viagens",
    home: SplashScreen(),
    */
    //Projeto Uber
    title: "Uber",
    home: HomeUber(),
    //theme: themaPadra,
    initialRoute: "/",
    onGenerateRoute: Rotas.gerarRotas,
    debugShowCheckedModeBanner: false,
  ));
}