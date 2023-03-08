import 'package:flutter/material.dart';

/* Stateless -> Widgets que não podem ser alterados(constates).
   Stateful -> Widgets que podem ser alterados(Variaveis).
* */

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Frases do dia",
    //Atributo para widgets
    // home: Row(children: [
    //   Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit ",
    //     style: TextStyle(fontSize: 20),),
    //   Text("T2: ")
    // ],),
    home: HomeStateful(),
  ));
}

class HomeStateful extends StatefulWidget {
  const HomeStateful({Key? key}) : super(key: key);

  @override
  State<HomeStateful> createState() => _HomeStatefulState();
}

class _HomeStatefulState extends State<HomeStateful> {
  @override
  Widget build(BuildContext context) {

    var _titulo = "Instagram";

    return Scaffold(
      //Barra superior do App
      appBar: AppBar(
        title: Text(_titulo),
        backgroundColor: Colors.green,
      ),
      //Corpo / Area Central
      body: Container(
        child: Column(
          children: <Widget>[
            FloatingActionButton(onPressed: (){
              //Altera o estado dos componentes
              setState(() {
                _titulo = "Uber";
              });
            },
                backgroundColor: Colors.lightBlue,
                child: Text("Click AQ.")) ,

          ],
        ),
      )

    );
  }
}


// Conferir doc. Não rodou
// class Home extends StatelessWidget {
//   const Home({Key? key}) : super(key: key);
//
//   var _titulo = "Instagram";
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       //Barra superior do App
//       appBar: AppBar(
//         title: Text(_titulo),
//         backgroundColor: Colors.green,
//       ),
//       //Corpo / Area Central
//       body: Text("Add mensagem no body"),
//       bottomNavigationBar: BottomAppBar(
//         color: Colors.green,
//         child: Padding(
//           padding: EdgeInsets.all(16),
//         ),
//       ),
//     );
//
//   }
// }
