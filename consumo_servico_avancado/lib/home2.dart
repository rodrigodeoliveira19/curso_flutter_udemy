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
    for (var post in dadosJson){
      print(post);
      Post newPost = Post(post["userId"], post["id"], post["title"], post["body"]);
      postagens.add(newPost);
    }
    return postagens;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Consumo de serviço avançado."),
      ),
      body: FutureBuilder<List<Post>>(
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
                      itemBuilder: (context, index){

                        List<Post>? lista = snapshot.data;
                        Post post = lista![index];

                        return ListTile(
                          title: Text( post.title ),
                          subtitle: Text( post.id.toString() ),
                        );

                      }
                  );
                }
                break;
            }

            return Center(
              child: Text(resultado),
            );
          },
          ),
    );
  }
}
