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
  Map<String, dynamic> _ultimaTarefaRemovida = Map();
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

  Widget _carregarItemLista(context, index){
    final item = _tarefas[index]["titulo"];

    return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (direction){

          //recuperar último item excluído
          _ultimaTarefaRemovida = _tarefas[index];

          //Remove item da lista
          _tarefas.removeAt(index);
          _salvarArquivo();

          //snackbar - Opção de desfazer a deleção
          final snackbar = SnackBar(
            //backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
            content: Text("Tarefa removida!!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: (){

                  //Insere novamente item removido na lista
                  setState(() {
                    _tarefas.insert(index, _ultimaTarefaRemovida);
                  });
                  _salvarArquivo();

                }
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackbar);

        },
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(
                Icons.delete,
                color: Colors.white,
              )
            ],
          ),
        ),
        child: CheckboxListTile(
          title: Text( _tarefas[index]['titulo'] ),
          value: _tarefas[index]['realizada'],
          onChanged: (valorAlterado){

            setState(() {
              _tarefas[index]['realizada'] = valorAlterado;
            });

            _salvarArquivo();

          },
        )
    );
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
                itemBuilder: _carregarItemLista,
                itemCount: _tarefas.length,
              ))
        ],
      ),
    );
  }
}
