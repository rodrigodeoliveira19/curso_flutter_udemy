import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Post.dart';

class Home2 extends StatefulWidget {
  const Home2({Key? key}) : super(key: key);

  @override
  State<Home2> createState() => _HomeState2();
}

class _HomeState2 extends State<Home2> {

  Future<List<Post>> _recuperarPostagens() async {
    String _url_Base = "https://jsonplaceholder.typicode.com";
    var uri = Uri.parse("$_url_Base/posts");

    http.Response response = await http.get(uri);
    var dadosJson = json.decode(response.body);

    List<Post> postagens = [];
    for (var post in dadosJson) {
      print(post);
      Post newPost =
          Post(post["userId"], post["id"], post["title"], post["body"]);
      postagens.add(newPost);
    }
    return postagens;
  }

  _post() async{
    String _url_Base = "https://jsonplaceholder.typicode.com";
    var uri = Uri.parse("$_url_Base/posts");

    http.Response response = await http.post(uri,
        body: json.encode({
          "userId": 1000000,
          "id": null,
          "title": "sunt",
          "body": "ok"
        }),
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        });

    print("reponse statusCode: ${response.statusCode}");
    print("reponse body: ${response.body}");
  }

  _put() async{
    String _url_Base = "https://jsonplaceholder.typicode.com";
    var uri = Uri.parse("$_url_Base/posts/2");

    Post post = new Post(1, 2, "Teste object", "Teste body");

    http.Response response = await http.put(uri,
        body: json.encode(post.toJson()),
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        });

    print("reponse statusCode: ${response.statusCode}");
    print("reponse body: ${response.body}");
  }

  _patch() async{
    String _url_Base = "https://jsonplaceholder.typicode.com";
    var uri = Uri.parse("$_url_Base/posts/2");

    http.Response response = await http.patch(uri,
        body: json.encode({
          "userId": 1,
          "id": 2,
          "title": "Exemplo de requisição put.",
        }),
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        });

    print("reponse statusCode: ${response.statusCode}");
    print("reponse body: ${response.body}");
  }

  _delete() async{
    String _url_Base = "https://jsonplaceholder.typicode.com";
    var uri = Uri.parse("$_url_Base/posts/2");

    http.Response response = await http.delete(uri,
        headers: {
          'Content-type': 'application/json; charset=UTF-8',
        });

    print("reponse statusCode: ${response.statusCode}");
    print("reponse body: ${response.body}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Consumo de serviço avançado."),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: _post,
                  child: Text(
                    "Salvar",
                    style: TextStyle(fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                ElevatedButton(
                  /* _put -> Atualiza todos os campos do Objeto.
                     _patch -> Atualiza campos específicos informados na requisição.
                  * */
                  onPressed: _put,
                  child: Text(
                    "Atualizar",
                    style: TextStyle(fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                ElevatedButton(
                  onPressed: _delete,
                  child: Text(
                    "Deletar",
                    style: TextStyle(fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
            //Expanded - Informa ao objeto child qto de espaço ele deve ocupar na tela
            Expanded(
                child: FutureBuilder<List<Post>>(
                  future: _recuperarPostagens(),
              //snapshot - permite acesso aos dados retornados em _recuperarPreco.
              builder: (context, snapshot) {
                String resultado;
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                    break;
                  case ConnectionState.active:
                  case ConnectionState.done:
                    print("conexao done");
                    if (snapshot.hasError) {
                      resultado = "Erro ao carregar os dados.";
                    } else {
                      return ListView.builder(
                          itemCount: snapshot.data?.length,
                          itemBuilder: (context, index) {
                            List<Post>? lista = snapshot.data;
                            Post post = lista![index];

                            return ListTile(
                              title: Text(post.title),
                              subtitle: Text(post.id.toString()),
                            );
                          });
                    }
                    break;
                }

                return Center(
                  child: Text(resultado),
                );
              },
            ))
          ],
        ),
      ),
    );
  }
}
