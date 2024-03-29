import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:minhas_viagens/uber/model/Requisicao.dart';
import 'package:minhas_viagens/uber/model/Usuario.dart';
import 'package:minhas_viagens/uber/util/UsuarioFirebase.dart';
import 'dart:async';
import 'dart:io';

import '../model/Destino.dart';
import '../model/Marcador.dart';
import '../util/StatusRequisicao.dart';
import 'package:intl/intl.dart';

class PainelPassageiro extends StatefulWidget {
  const PainelPassageiro({Key? key}) : super(key: key);

  @override
  State<PainelPassageiro> createState() => _PainelPassageiroState();
}

class _PainelPassageiroState extends State<PainelPassageiro> {
  List<String> itensMenu = ["Configurações", "Deslogar"];
  TextEditingController _controllerDestino =
      TextEditingController(text: "Av. Paulista");
  Completer<GoogleMapController> _mapController = Completer();
  CameraPosition _posicaoCamera = CameraPosition(
    target: LatLng(-23.563370, -46.652923),
    //zoom: 16,
  );

  //Marcadores de locais no mapa
  Set<Marker> _marcadores = {};

  // Controles para exibição de componentes na tela.
  bool _exibirCaixaEnderecoDestino = true;
  String _textoBotao = "Chamar Uber";
  Color _corBotao = Colors.blue;
  var _funcaoBotao;
  late String _idRequisicao = "";
  late Position _localPassageiro;
  late Map<dynamic, dynamic> _dadosRequisicao = {'status':'NAO_RECUPERADO'};

  late StreamSubscription<DocumentSnapshot> _streamSubscriptionRequisicoes;

  _deslogarUsuario() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacementNamed(context, "/");
  }

  _escolhaMenuItem(String escolha) {
    switch (escolha) {
      case "Deslogar":
        _deslogarUsuario();
        break;
      case "Configurações":
        break;
    }
  }

  _onMapCreated(GoogleMapController mapController) {
    _mapController.complete(mapController);
  }

  _adicionarListenerLocalizacao() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    // StreamSubscription<Position> positionStream =
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      print(position == null
          ? 'Local: Unknown'
          : 'Posicao atual: ${position.latitude.toString()}, ${position.longitude.toString()}');
      // _localPassageiro = position;

      if (_idRequisicao.isNotEmpty) {
        //Atualizar o lacal do passageiro
        UsuarioFirebase.atualizarDadosLocalizacao(
            _idRequisicao, position.latitude, position.longitude, "passageiro");
       } //else{
      //   setState(() {
      //     _posicaoCamera = CameraPosition(
      //         target: LatLng(position.latitude, position.longitude), zoom: 19);
      //     _localPassageiro = position;
      //     _exibirMarcadorPassageiro(position);
      //     _movimentarCamera();
      //   });
      //   //_statusUberNaoChamado();
      // }

      setState(() {
        _posicaoCamera = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 19);
        _localPassageiro = position;
        _exibirMarcadorPassageiro(position);
        _movimentarCamera();
      });
    });
  }

  _movimentarCamera() async {
    GoogleMapController googleMapController = await _mapController.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(_posicaoCamera));
  }

  void _exibirMarcadorPassageiro(Position position) async {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: pixelRatio),
            "imagens/uber/passageiro.png")
        .then((BitmapDescriptor icon) {
      Marker marcadorPassageiro = Marker(
          markerId: MarkerId("${position.latitude} - "
              "${position.longitude} - "
              "marcador-passageiro"),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(title: "Meu Local"),
          icon: icon,
          onTap: () {
            print("Cartório clicado!!");
          });

      setState(() {
        _marcadores.add(marcadorPassageiro);
      });
    });
  }

  void _chamarUber() async {
    String enderecoDestino = _controllerDestino.text;
    if (enderecoDestino.isNotEmpty) {
      List<Location> locations =
          await locationFromAddress(_controllerDestino.text);
      print("Endereços2: " + locations.toString());

      if (locations.isNotEmpty) {
        //Obtendo o endereço a partir da latitude e longitude.
        List<Placemark> placemarks = await placemarkFromCoordinates(
            locations[0].latitude, locations[0].longitude);

        if (placemarks.length > 0) {
          Placemark endereco = placemarks[0];

          Destino destino = Destino();
          destino.cidade = endereco.subAdministrativeArea!;
          destino.cep = endereco.postalCode!;
          destino.bairro = endereco.subLocality!;
          destino.rua = endereco.thoroughfare!;
          destino.numero = endereco.subThoroughfare!;

          destino.latitude = locations[0].latitude;
          destino.longitude = locations[0].longitude;

          String enderecoConfirmacao;
          enderecoConfirmacao = "\n Cidade: " + destino.cidade;
          enderecoConfirmacao +=
              "\n Rua: " + destino.rua + ", " + destino.numero;
          enderecoConfirmacao += "\n Bairro: " + destino.bairro;
          enderecoConfirmacao += "\n Cep: " + destino.cep;

          showDialog(
              context: context,
              builder: (contex) {
                return AlertDialog(
                  title: Text("Confirmação do endereço"),
                  content: Text(enderecoConfirmacao),
                  contentPadding: EdgeInsets.all(16),
                  actions: <Widget>[
                    ElevatedButton(
                      child: Text(
                        "Cancelar",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () => Navigator.pop(contex),
                    ),
                    ElevatedButton(
                      child: Text(
                        "Confirmar",
                        style: TextStyle(color: Colors.green),
                      ),
                      onPressed: () {
                        //salvar requisicao
                        _salvarRequisicao(destino);

                        Navigator.pop(contex);
                      },
                    )
                  ],
                );
              });
        }
      }
    }
  }

  Future<void> _salvarRequisicao(Destino destino) async {
    Usuario usuario = await UsuarioFirebase.getUsuarioLogado();
    usuario.latitude = destino.latitude;
    usuario.longitude = destino.longitude;

    Requisicao requisicao = Requisicao();
    requisicao.destino = destino;
    requisicao.status = StatusRequisicao.AGUARDANDO;
    requisicao.passageiro = usuario;

    FirebaseFirestore db = FirebaseFirestore.instance;
    //Obtem o id disponivel antes de realizar inserção.
    String idRequisicao = db.collection("requisicoes").doc().id;
    requisicao.id = idRequisicao;
    db.collection("requisicoes").doc(idRequisicao).set(requisicao.toMap());

    //Salvar requisição ativa
    Map<String, dynamic> dadosRequisicaoAtiva = {};
    dadosRequisicaoAtiva["id_requisicao"] = requisicao.id;
    dadosRequisicaoAtiva["id_usuario"] = usuario.idUsuario;
    dadosRequisicaoAtiva["status"] = StatusRequisicao.AGUARDANDO;

    db
        .collection("requisicao_ativa")
        .doc(usuario.idUsuario)
        .set(dadosRequisicaoAtiva);

    //chamara o metodo para alterar a interface para o status aguardando
    //_statusAguardando();
    _adicionarListenerRequisicao(requisicao.id);
  }

  _statusUberNaoChamado() {
    _exibirCaixaEnderecoDestino = true;
    _alterarBotaoPrincipal("Chamar uber", Color(0xff1ebbd8), () {
      _chamarUber();
    });

    // Position position = Position(
    //     latitude: _localPassageiro.latitude,
    //     longitude: _localPassageiro.longitude
    // );

    // if(_localPassageiro != null){
    //   _exibirMarcadorPassageiro(_localPassageiro);
    //   _posicaoCamera = CameraPosition(
    //       target: LatLng(_localPassageiro.latitude, _localPassageiro.longitude), zoom: 19);
    //   _movimentarCamera();
    //
    // }

  }

  _alterarBotaoPrincipal(String texto, Color cor, Function funcao) {
    setState(() {
      _textoBotao = texto;
      _corBotao = cor;
      _funcaoBotao = funcao;
    });
  }

  _statusAguardando() {
    print("Metodo _statusAguardando");
    _exibirCaixaEnderecoDestino = false;
    _alterarBotaoPrincipal("Cancelar", Colors.red, () {
      _cancelarUber();
    });

    //Movimentou a camera como no  metodo _statusUberNaoChamado
  }

  _statusACaminho() {
    _exibirCaixaEnderecoDestino = false;
    _alterarBotaoPrincipal("Motorista a caminho", Colors.grey, () {
      // _cancelarUber();
    });

    double latitudePassageiro = _dadosRequisicao["passageiro"]["latitude"];
    double longitudePassageiro = _dadosRequisicao["passageiro"]["longitude"];

    double latitudeMotorista = _dadosRequisicao["motorista"]["latitude"];
    double longitudeMotorista = _dadosRequisicao["motorista"]["longitude"];

    // _exibirDoisMarcadores(LatLng(latitudePassageiro, longitudePassageiro),
    //     LatLng(latitudeMotorista, longitudeMotorista));

    Marcador marcadorOrigem = Marcador(
        LatLng(latitudePassageiro, longitudePassageiro),
        "imagens/uber/passageiro.png",
        "Local passageiro"
    );

    Marcador marcadorDestino = Marcador(
        LatLng(latitudeMotorista, longitudeMotorista),
        "imagens/uber/motorista.png",
        "Local motorista"
    );

    _exibirCentralizarDoisMarcadores(marcadorOrigem, marcadorDestino);

    var northLat, northLong, sountLat, sountLong;
    if(latitudeMotorista <= latitudePassageiro){
      sountLat = latitudeMotorista;
      northLat = latitudePassageiro;
    }else{
      sountLat = latitudePassageiro;
      northLat = latitudeMotorista;
    }

    if(longitudeMotorista <= longitudePassageiro){
      sountLong = longitudeMotorista;
      northLong = longitudePassageiro;
    }else{
      sountLong = longitudePassageiro;
      northLong = longitudeMotorista;
    }
    _movimentarCameraBounds(
        LatLngBounds(southwest: LatLng(sountLat, sountLong),
            northeast: LatLng(northLat, northLong))
    );

  }

  _statusEmViagem() {
    _exibirCaixaEnderecoDestino = false;
    _alterarBotaoPrincipal(
        "Em viagem",
        Colors.grey,
        (){}
    );

    double latitudeDestino = _dadosRequisicao["destino"]["latitude"];
    double longitudeDestino = _dadosRequisicao["destino"]["longitude"];

    double latitudeOrigem = _dadosRequisicao["motorista"]["latitude"];
    double longitudeOrigem = _dadosRequisicao["motorista"]["longitude"];

    Marcador marcadorOrigem = Marcador(
        LatLng(latitudeOrigem, longitudeOrigem),
        "imagens/uber/motorista.png",
        "Local motorista"
    );

    Marcador marcadorDestino = Marcador(
        LatLng(latitudeDestino, longitudeDestino),
        "imagens/uber/destino.png",
        "Local destino"
    );

    _exibirCentralizarDoisMarcadores(marcadorOrigem, marcadorDestino);

  }

  _statusFinalizada() async {

    //Calcula valor da corrida
    double latitudeDestino = _dadosRequisicao["destino"]["latitude"];
    double longitudeDestino = _dadosRequisicao["destino"]["longitude"];

    double latitudeOrigem = _dadosRequisicao["origem"]["latitude"];
    double longitudeOrigem = _dadosRequisicao["origem"]["longitude"];

    double distanciaEmMetros = await Geolocator.distanceBetween(
        latitudeOrigem,
        longitudeOrigem,
        latitudeDestino,
        longitudeDestino
    );

    //Converte para KM
    double distanciaKm = distanciaEmMetros / 1000;

    //8 é o valor cobrado por KM
    double valorViagem = distanciaKm * 8;

    //Formatar valor viagem
    var f = NumberFormat("#,##0.00", "pt_BR");
    var valorViagemFormatado = f.format( valorViagem );

    _alterarBotaoPrincipal(
        "Total: - R\$ ${valorViagemFormatado}",
        Color(0xff1ebbd8),
            (){}
    );

    _marcadores = {};
    Position position = Position(longitude: longitudeDestino, latitude: latitudeDestino, timestamp: null, accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0);
    // Position position = _localMotorista;
    _posicaoCamera = CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 18);
    _exibirMarcador(position,"imagens/uber/destino.png","Destino");
    _movimentarCamera();

  }

  _statusConfirmada(){
    _streamSubscriptionRequisicoes.cancel();

    _exibirCaixaEnderecoDestino = true;
    _alterarBotaoPrincipal(
        "Chamar uber",
        Color(0xff1ebbd8), () {
      _chamarUber();
    });

    _dadosRequisicao = {};
  }

  void _exibirMarcador(
      Position position, String icone, String infoWindow) async {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio), icone)
        .then((BitmapDescriptor bitmapDescriptor) {
      Marker marcador = Marker(
          markerId: MarkerId(icone),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(title: infoWindow),
          icon: bitmapDescriptor,
          onTap: () {
            print("Cartório clicado!!");
          });

      setState(() {
        _marcadores.add(marcador);
      });
    });
  }

  _exibirCentralizarDoisMarcadores( Marcador marcadorOrigem, Marcador marcadorDestino ){

    double latitudeOrigem = marcadorOrigem.local.latitude;
    double longitudeOrigem = marcadorOrigem.local.longitude;

    double latitudeDestino = marcadorDestino.local.latitude;
    double longitudeDestino = marcadorDestino.local.longitude;

    //Exibir dois marcadores
    _exibirDoisMarcadores(
        marcadorOrigem,
        marcadorDestino
    );

    //'southwest.latitude <= northeast.latitude': is not true
    var nLat, nLon, sLat, sLon;

    if( latitudeOrigem <=  latitudeDestino ){
      sLat = latitudeOrigem;
      nLat = latitudeDestino;
    }else{
      sLat = latitudeDestino;
      nLat = latitudeOrigem;
    }

    if( longitudeOrigem <=  longitudeDestino ){
      sLon = longitudeOrigem;
      nLon = longitudeDestino;
    }else{
      sLon = longitudeDestino;
      nLon = longitudeOrigem;
    }
    //-23.560925, -46.650623
    _movimentarCameraBounds(
        LatLngBounds(
            northeast: LatLng(nLat, nLon), //nordeste
            southwest: LatLng(sLat, sLon) //sudoeste
        )
    );

  }

  // _exibirDoisMarcadores(LatLng latLngPassageiro, LatLng latLngMotorista){
  //   double pixelRatio = MediaQuery.of(context).devicePixelRatio;
  //
  //   Set<Marker> _listaMarcadores = {};
  //   BitmapDescriptor.fromAssetImage(
  //       ImageConfiguration(devicePixelRatio: pixelRatio),
  //       "imagens/uber/motorista.png")
  //       .then((BitmapDescriptor icon) {
  //     Marker marcadorMotorista = Marker(
  //         markerId: MarkerId("${latLngMotorista.latitude} - "
  //             "${latLngMotorista.longitude} - "
  //             "marcador-motorista"),
  //         position: latLngMotorista,
  //         infoWindow: InfoWindow(title: "Local Motorista"),
  //         icon: icon);
  //
  //     _listaMarcadores.add(marcadorMotorista);
  //   });
  //
  //   BitmapDescriptor.fromAssetImage(
  //       ImageConfiguration(devicePixelRatio: pixelRatio),
  //       "imagens/uber/passageiro.png")
  //       .then((BitmapDescriptor icon) {
  //     Marker marcadorPassageiro = Marker(
  //         markerId: MarkerId("${latLngPassageiro.latitude} - "
  //             "${latLngPassageiro.longitude} - "
  //             "marcador-passageiro"),
  //         position: latLngPassageiro,
  //         infoWindow: InfoWindow(title: "Local passageiro"),
  //         icon: icon);
  //
  //     _listaMarcadores.add(marcadorPassageiro);
  //   });
  //
  //   setState(() {
  //     _marcadores = _listaMarcadores;
  //     // _posicaoCamera = CameraPosition(target: latLngMotorista, zoom: 25);
  //     // _movimentarCamera();
  //   });
  // }

  _exibirDoisMarcadores( Marcador marcadorOrigem, Marcador marcadorDestino ){

    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    LatLng latLngOrigem = marcadorOrigem.local;
    LatLng latLngDestino = marcadorDestino.local;

    Set<Marker> _listaMarcadores = {};
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        marcadorOrigem.caminhoImagem)
        .then((BitmapDescriptor icone) {
      Marker mOrigem = Marker(
          markerId: MarkerId(marcadorOrigem.caminhoImagem),
          position: LatLng(latLngOrigem.latitude, latLngOrigem.longitude),
          infoWindow: InfoWindow(title: marcadorOrigem.titulo),
          icon: icone);
      _listaMarcadores.add( mOrigem );
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        marcadorDestino.caminhoImagem)
        .then((BitmapDescriptor icone) {
      Marker mDestino = Marker(
          markerId: MarkerId(marcadorDestino.caminhoImagem),
          position: LatLng(latLngDestino.latitude, latLngDestino.longitude),
          infoWindow: InfoWindow(title: marcadorDestino.titulo),
          icon: icone);
      _listaMarcadores.add( mDestino );
    });

    setState(() {
      _marcadores = _listaMarcadores;
    });

  }

  _movimentarCameraBounds(LatLngBounds latLngBounds) async {
    GoogleMapController googleMapController = await _mapController.future;
    googleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 100));
  }

  _cancelarUber() async {
    User? user = await UsuarioFirebase.getUsuarioAtual();
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db
        .collection("requisicoes")
        .doc(_idRequisicao)
        .update({"status": StatusRequisicao.CANCELADA}).then(
            (_) => {db.collection("requisicao_ativa").doc(user?.uid).delete()});
    _statusUberNaoChamado();
    _streamSubscriptionRequisicoes.cancel();
  }

  // _adicionarListenerRequisicaoAtiva() async {
  //   User? user = await UsuarioFirebase.getUsuarioAtual();
  //
  //   FirebaseFirestore db = FirebaseFirestore.instance;
  //   await db
  //       .collection("requisicao_ativa")
  //       .doc(user?.uid)
  //       .snapshots()
  //       .listen((snapshot) {
  //     //print("dados recuperados: " + snapshot.data.toString() );
  //
  //     /*
  //           Caso tenha uma requisicao ativa
  //             -> altera interface de acordo com status
  //           Caso não tenha
  //             -> Exibe interface padrão para chamar uber
  //       */
  //     if (snapshot.data() != null) {
  //       var dados = snapshot.data() as Map;
  //       String status = dados["status"];
  //       _idRequisicao = dados["id_requisicao"];
  //
  //       switch (status) {
  //         case StatusRequisicao.AGUARDANDO:
  //           _statusAguardando();
  //           break;
  //         case StatusRequisicao.A_CAMINHO:
  //           _statusACaminho();
  //           break;
  //         case StatusRequisicao.VIAGEM:
  //           break;
  //         case StatusRequisicao.FINALIZADA:
  //           break;
  //       }
  //     } else {
  //       _statusUberNaoChamado();
  //     }
  //   });
  // }

  _recuperarRequisicaoAtiva() async {

    User? user = await UsuarioFirebase.getUsuarioAtual();

    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot documentSnapshot = await db
        .collection("requisicao_ativa")
        .doc(user?.uid)
        .get();

    if( documentSnapshot.data() != null ){
      var dados = documentSnapshot.data() as Map;
      _idRequisicao = dados["id_requisicao"];
      _adicionarListenerRequisicao( _idRequisicao );

    }else{
      _statusUberNaoChamado();
    }
  }

  _adicionarListenerRequisicao(String idRequisicao) async {
    User? user = await UsuarioFirebase.getUsuarioAtual();
    print("id usuario: ${user!.uid}");

    FirebaseFirestore db = FirebaseFirestore.instance;
    _streamSubscriptionRequisicoes = await db
        .collection("requisicoes")
        .doc(
            idRequisicao) //Entender se o listner é no documento da requisição ativa(id usuario) ou no documento da requisição.
        .snapshots()
        .listen((snapshot) {
      //print("dados recuperados: " + snapshot.data.toString() );

      /*
            Caso tenha uma requisicao ativa
              -> altera interface de acordo com status
            Caso não tenha
              -> Exibe interface padrão para chamar uber
        */
      if (snapshot.data() != null) {
        var dados = snapshot.data() as Map;
        _dadosRequisicao = dados;
        String status = dados["status"];
        _idRequisicao = dados["id_requisicao"];

        switch (status) {
          case StatusRequisicao.AGUARDANDO:
            print("passssssssssssssei por aqui");
            _statusAguardando();
            break;
          case StatusRequisicao.A_CAMINHO:
            _statusACaminho();
            break;
          case StatusRequisicao.VIAGEM:
            _statusEmViagem();
            break;
          case StatusRequisicao.FINALIZADA:
            _statusFinalizada();
            break;
          case StatusRequisicao.CONFIRMADA:
            _statusConfirmada();
            break;
        }
      } else {
        _statusUberNaoChamado();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _recuperarRequisicaoAtiva();
    _adicionarListenerLocalizacao();

    /*Antigo _adicionarListenerRequisicaoAtiva()*/
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscriptionRequisicoes.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Painel passageiro"),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            itemBuilder: (context) {
              return itensMenu.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Container(
          //Stack - Empilha os itens na ordem de inserção.
          child: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _posicaoCamera,
            //Constroi o mapa
            onMapCreated: _onMapCreated,
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            //onLongPress: _adicionarMarcador,
            markers: _marcadores,
          ),
          Visibility(
              visible: _exibirCaixaEnderecoDestino,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.white),
                        child: TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                              icon: Container(
                                margin: EdgeInsets.only(left: 20),
                                width: 10,
                                height: 10,
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.green,
                                ),
                              ),
                              hintText: "Meu local",
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.only(left: 15, top: 16)),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 55,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.white),
                        child: TextField(
                          controller: _controllerDestino,
                          decoration: InputDecoration(
                              icon: Container(
                                margin: EdgeInsets.only(left: 20),
                                width: 10,
                                height: 10,
                                child: Icon(
                                  Icons.local_taxi,
                                  color: Colors.black,
                                ),
                              ),
                              hintText: "Digite o destino",
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.only(left: 15, top: 16)),
                        ),
                      ),
                    ),
                  )
                ],
              )),
          Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: Padding(
              padding: Platform.isIOS
                  ? EdgeInsets.fromLTRB(20, 10, 20, 25)
                  : EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: _funcaoBotao, // _funcaoBotao _chamarUber
                child: Text(
                  _textoBotao,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _corBotao,
                  padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                ),
              ),
            ),
          )
        ],
      )),
    );
  }
}
