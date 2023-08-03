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
        title: Text("Lista de tarefas."),
        backgroundColor: Colors.purple,
      ),
      body: Text("Conteudo"),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.purple,
        icon: Icon(Icons.add_shopping_cart),
        label: Text("Adicionar"),
        // child: Icon(Icons.add),
        onPressed: () {
          print("Botão precionado.");
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(onPressed: (){}, icon: Icon(Icons.add))
          ],
        ),
      ),
    );
  }
}
