import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _tarefas = [];
  TextEditingController _controllerTarefa = TextEditingController();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  _salvarArquivo() async {
    var arquivo = await _getFile();

    String dados = json.encode(_tarefas);
    print("_salvarArquivo: "+dados.toString()); 
    arquivo.writeAsString(dados);
  }

  _lerArquivo() async {
    try {
      final arquivo = await _getFile();
      return arquivo.readAsString();
    } catch (ex) {
      return null;
    }
  }

  _salvarTarefa() {
    String textoDigitado = _controllerTarefa.text;
    Map<String, dynamic> tarefas = Map();
    tarefas["titulo"] = textoDigitado;
    tarefas["realizada"] = false;

    setState(() {
      _tarefas.add(tarefas);
    });
    _salvarArquivo();
    _controllerTarefa.text = "";
  }

  @override
  void initState() {
    super.initState();

    _lerArquivo().then((dados) {
      setState(() {
        _tarefas = json.decode(dados);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // _salvarArquivo();
    print("Itens: " + _tarefas.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.purple,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.purple,
        icon: Icon(Icons.add),
        label: Text("Adicionar"),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Adicionar tarefa"),
                  content: TextField(
                    controller: _controllerTarefa,
                    decoration:
                    InputDecoration(label: Text("Digite sua tarefa")),
                    onChanged: (text) {},
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Cancelar",
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _salvarTarefa();
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Salvar",
                        style: TextStyle(fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ],
                );
              });
        },
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                  title: Text(_tarefas[index]["titulo"]),
                  value: _tarefas[index]["realizada"],
                  onChanged: (valorAlterado) {

                    setState(() {
                      _tarefas[index]["realizada"] = valorAlterado;
                    });

                    _salvarArquivo();
                  });
              // return ListTile(
                  //   title: Text(_tarefas[index]["titulo"]),
                  // );
                },
                itemCount: _tarefas.length,
              ))
        ],
      ),
    );
  }
}
