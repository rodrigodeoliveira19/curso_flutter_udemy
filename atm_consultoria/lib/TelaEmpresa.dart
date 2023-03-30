import 'package:flutter/material.dart';

class TelaEmpresa extends StatefulWidget {
  const TelaEmpresa({Key? key}) : super(key: key);

  @override
  State<TelaEmpresa> createState() => _TelaEmpresaState();
}

class _TelaEmpresaState extends State<TelaEmpresa> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Empresa"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset("imagens/detalhe_empresa.png"),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      "Sobre a empresa",
                      style: TextStyle(fontSize: 20, color: Colors.deepOrange),
                    ),
                  )
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 16),
              child: Text("Lorem ipsum dolor sit amet. Et cumque consequatur eos asperiores ratione est omnis incidunt in dolorem nihil qui dolor consequatur aut velit facere et quis culpa. Et aperiam dicta aut repudiandae sint quo labore quasi. Et omnis consequatur non omnis corporis sit officia voluptas quo voluptate nulla."
                  "Lorem ipsum dolor sit amet. Et cumque consequatur eos asperiores ratione est omnis incidunt in dolorem nihil qui dolor consequatur aut velit facere et quis culpa. Et aperiam dicta aut repudiandae sint quo labore quasi. Et omnis consequatur non omnis corporis sit officia voluptas quo voluptate nulla."
                  "Lorem ipsum dolor sit amet. Et cumque consequatur eos asperiores ratione est omnis incidunt in dolorem nihil qui dolor consequatur aut velit facere et quis culpa. Et aperiam dicta aut repudiandae sint quo labore quasi. Et omnis consequatur non omnis corporis sit officia voluptas quo voluptate nulla."
                  "Lorem ipsum dolor sit amet. Et cumque consequatur eos asperiores ratione est omnis incidunt in dolorem nihil qui dolor consequatur aut velit facere et quis culpa. Et aperiam dicta aut repudiandae sint quo labore quasi. Et omnis consequatur non omnis corporis sit officia voluptas quo voluptate nulla."
                  "Lorem ipsum dolor sit amet. Et cumque consequatur eos asperiores ratione est omnis incidunt in dolorem nihil qui dolor consequatur aut velit facere et quis culpa. Et aperiam dicta aut repudiandae sint quo labore quasi. Et omnis consequatur non omnis corporis sit officia voluptas quo voluptate nulla."
                  "Lorem ipsum dolor sit amet. Et cumque consequatur eos asperiores ratione est omnis incidunt in dolorem nihil qui dolor consequatur aut velit facere et quis culpa. Et aperiam dicta aut repudiandae sint quo labore quasi. Et omnis consequatur non omnis corporis sit officia voluptas quo voluptate nulla."
                  "Lorem ipsum dolor sit amet. Et cumque consequatur eos asperiores ratione est omnis incidunt in dolorem nihil qui dolor consequatur aut velit facere et quis culpa. Et aperiam dicta aut repudiandae sint quo labore quasi. Et omnis consequatur non omnis corporis sit officia voluptas quo voluptate nulla."
                  "Lorem ipsum dolor sit amet. Et cumque consequatur eos asperiores ratione est omnis incidunt in dolorem nihil qui dolor consequatur aut velit facere et quis culpa. Et aperiam dicta aut repudiandae sint quo labore quasi. Et omnis consequatur non omnis corporis sit officia voluptas quo voluptate nulla."),)
            ],
          ),
        ),
      ),
    );
  }
}
