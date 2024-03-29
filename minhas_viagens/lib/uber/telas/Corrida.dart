import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/Usuario.dart';
import '../util/StatusRequisicao.dart';
import '../util/UsuarioFirebase.dart';
import 'package:intl/intl.dart';

class Corrida extends StatefulWidget {
  String idRequisicao;

  Corrida(this.idRequisicao);

  @override
  State<Corrida> createState() => _CorridaState();
}

class _CorridaState extends State<Corrida> {
  bool _pegueiAlocalizacao = false;
  List<String> itensMenu = [
    "Configurações", "Deslogar"
  ];

  Completer<GoogleMapController> _mapController = Completer();
  CameraPosition _posicaoCamera = CameraPosition(
    target: LatLng(-23.563370, -46.652923),
    zoom: 16,
  );

  //Marcadores de locais no mapa
  Set<Marker> _marcadores = {};
  late Position _localMotorista;

  // Controles para exibição de componentes na tela.
  String _textoBotao = "Aceitar corrida";
  Color _corBotao = Colors.blue;
  var _funcaoBotao;
  String _mensagemStatus = "";
  late String _idRequisicao;
  String _statusRequisicao = StatusRequisicao.AGUARDANDO;

  //Requisicao
  late Map<String,dynamic> _dadosRequisicao;

  _alterarBotaoPrincipal(String texto, Color cor, Function funcao) {
    setState(() {
      _textoBotao = texto;
      _corBotao = cor;
      _funcaoBotao = funcao;
    });
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

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      print(position == null
          ? 'Local: Unknown'
          : 'Posicao atual: ${position.latitude.toString()}, ${position.longitude.toString()}');

      _pegueiAlocalizacao = true;
      setState(() {
        // _movimentarCamera();
        _localMotorista = position;
      });
      if (widget.idRequisicao.isNotEmpty) {
        if (_statusRequisicao != StatusRequisicao.AGUARDANDO)
          UsuarioFirebase.atualizarDadosLocalizacao(widget.idRequisicao,
              position.latitude, position.longitude, "motorista");
        else{//Aguardando
          // setState(() {
          //   // _movimentarCamera();
          //   _localMotorista = position;
          // });
          _statusAguardando();
        }
      }

    });
  }

  _movimentarCamera() async {
    GoogleMapController googleMapController = await _mapController.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(_posicaoCamera));
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

  _recuperarRequisicao() async{
    String idRequisicao = widget.idRequisicao;

    FirebaseFirestore db = FirebaseFirestore.instance;
    //Get Requisicao
    DocumentSnapshot snapshot =
    await db.collection("requisicoes").doc( idRequisicao ).get();
  }

  _adicionarListenerRequisicao() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    // String idRequisicao = _dadosRequisicao["id_requisicao"];
    print("id requisicao ${widget.idRequisicao}");
    await db
        .collection("requisicoes")
        .doc(widget.idRequisicao)
        .snapshots()
        .listen((event) {
      if (event.data() != null) {
        _dadosRequisicao = event.data() as Map<String,dynamic>;

        var requisicao = event.data() as Map;
        _statusRequisicao = requisicao["status"];

        switch (_statusRequisicao) {
          case StatusRequisicao.AGUARDANDO:
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

      }
    });
  }

  _statusAguardando() {
    _alterarBotaoPrincipal("Aceitar Corrida", Color(0xff1ebbd8), () {
      _aceitarCorrida();
    });

    if(_pegueiAlocalizacao){
      double motoristaLat = _localMotorista.latitude;
      double motoristaLog = _localMotorista.longitude;

      // double motoristaLat = _dadosRequisicao["motorista"]["latitude"];
      // double motoristaLog = _dadosRequisicao["motorista"]["longitude"];

      // Revisar esse ponto. Na aula o professor cria um novo Position. Porem já existe um listner para a posicao do motorista.
      Position position = Position(longitude: motoristaLog, latitude: motoristaLat, timestamp: null, accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0);
      // Position position = _localMotorista;
      _posicaoCamera = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 19);
      _exibirMarcador(position,"imagens/uber/motorista.png","Motorista");
      _movimentarCamera();
    }

  }

  _statusACaminho() {
    _mensagemStatus = "A caminho do passageiro";
    _alterarBotaoPrincipal("Iniciar corrida", Color(0xff1ebbd8), (){ _IniciarCorrida(); });

    double latitudePassageiro = _dadosRequisicao["passageiro"]["latitude"];
    double longitudePassageiro = _dadosRequisicao["passageiro"]["longitude"];

    double latitudeMotorista = _dadosRequisicao["motorista"]["latitude"];
    double longitudeMotorista = _dadosRequisicao["motorista"]["longitude"];

    _exibirDoisMarcadores(LatLng(latitudePassageiro, longitudePassageiro),
        LatLng(latitudeMotorista, longitudeMotorista));

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
    _mensagemStatus = "Em viagem";
    _alterarBotaoPrincipal("Finalizar corrida", Color(0xff1ebbd8), (){ _finalizarCorrida(); });

    double latitudeDestino = _dadosRequisicao["destino"]["latitude"];
    double longitudeDestino = _dadosRequisicao["destino"]["longitude"];

    double latitudeOrigem = _dadosRequisicao["origem"]["latitude"];
    double longitudeOrigem = _dadosRequisicao["origem"]["longitude"];

    _exibirDoisMarcadores(LatLng(latitudeOrigem, longitudeDestino),
        LatLng(latitudeOrigem, longitudeOrigem));

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

  _IniciarCorrida() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("requisicoes").doc(widget.idRequisicao).update({
      "origem": {
        "latitude": _dadosRequisicao["motorista"]["latitude"],
        "longitude": _dadosRequisicao["motorista"]["longitude"]
      },
      "status": StatusRequisicao.VIAGEM
    }).then((_) {

      //atualiza requisicao ativa
      String idPassageiro = _dadosRequisicao["passageiro"]["idUsuario"];
      db.collection("requisicao_ativa").doc(idPassageiro).update({
        "status": StatusRequisicao.VIAGEM,
      });

      //Salvar requisicao ativa para motorista
      String idMotorista = _dadosRequisicao["motorista"]["idUsuario"];
      db.collection("requisicao_ativa_motorista").doc(idMotorista).update({
        "status": StatusRequisicao.VIAGEM,
      });

    });
  }

  _finalizarCorrida(){
    FirebaseFirestore db = FirebaseFirestore.instance;
    db
        .collection("requisicoes")
        .doc(widget.idRequisicao)
        .update({"status": StatusRequisicao.FINALIZADA})
    .then((_){
      String idPassageiro = _dadosRequisicao["passageiro"]["idUsuario"];
      db
          .collection("requisicao_ativa")
          .doc(idPassageiro)
          .update({"status": StatusRequisicao.FINALIZADA});

      //Salvar requisição ativa para motorista
      String idMotorista = _dadosRequisicao["motorista"]["idUsuario"];
      db.collection("requisicao_ativa_motorista").doc(idMotorista).update({
        "status": StatusRequisicao.FINALIZADA
      });
    });
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
    //
    _mensagemStatus = "Viagem finalizada";
    _alterarBotaoPrincipal(
        "Confirmar - R\$ ${valorViagemFormatado}",
        Color(0xff1ebbd8),
            (){
          _confirmarCorrida();
        }
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
    Navigator.pushReplacementNamed(context, "/painel-motorista");
  }

  _confirmarCorrida(){
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("requisicoes")
        .doc( widget.idRequisicao )
        .update({
      "status" : StatusRequisicao.CONFIRMADA
    });

    String idPassageiro = _dadosRequisicao["passageiro"]["idUsuario"];
    db.collection("requisicao_ativa")
        .doc( idPassageiro )
        .delete();

    String idMotorista = _dadosRequisicao["motorista"]["idUsuario"];
    db.collection("requisicao_ativa_motorista")
        .doc( idMotorista )
        .delete();
  }

  /*Centraliza os marcadores no mapa.
  Requisito 'southwest.latitude <= northeast.latitude'
  Valores de sudoeste devem ser menores.
  * */
  _movimentarCameraBounds(LatLngBounds latLngBounds) async {
    GoogleMapController googleMapController = await _mapController.future;
    googleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 100));
  }

  //Exibe o marcador do passageiro e do motorista na interface
  _exibirDoisMarcadores(LatLng latLngPassageiro, LatLng latLngMotorista){
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    Set<Marker> _listaMarcadores = {};
    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        "imagens/uber/motorista.png")
        .then((BitmapDescriptor icon) {
      Marker marcadorMotorista = Marker(
          markerId: MarkerId("${latLngMotorista.latitude} - "
              "${latLngMotorista.longitude} - "
              "marcador-motorista"),
          position: latLngMotorista,
          infoWindow: InfoWindow(title: "Local Motorista"),
          icon: icon);

      _listaMarcadores.add(marcadorMotorista);
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        "imagens/uber/passageiro.png")
        .then((BitmapDescriptor icon) {
      Marker marcadorPassageiro = Marker(
          markerId: MarkerId("${latLngPassageiro.latitude} - "
              "${latLngPassageiro.longitude} - "
              "marcador-passageiro"),
          position: latLngPassageiro,
          infoWindow: InfoWindow(title: "Local passageiro"),
          icon: icon);

      _listaMarcadores.add(marcadorPassageiro);
    });

    setState(() {
      _marcadores = _listaMarcadores;
      // _posicaoCamera = CameraPosition(target: latLngMotorista, zoom: 25);
      // _movimentarCamera();
    });
  }

  _aceitarCorrida() async{
    //Recuperar dados do Motorista
    Usuario usuarioMotorista = await UsuarioFirebase.getUsuarioLogado();
    usuarioMotorista.latitude = _localMotorista.latitude;
    usuarioMotorista.longitude = _localMotorista.longitude;

    // usuarioMotorista.latitude = _dadosRequisicao["motorista"]["latitude"];
    // usuarioMotorista.longitude = _dadosRequisicao["motorista"]["longitude"];

    FirebaseFirestore db = FirebaseFirestore.instance;
    String idRequisicao = _dadosRequisicao["id_requisicao"];

    db.collection("requisicoes").doc(idRequisicao).update({
      "motorista": usuarioMotorista.toMap(),
      "status": StatusRequisicao.A_CAMINHO
    }).then((_) {
      //Atualizar requisição ativa do passageiro
      String idPassageiro = _dadosRequisicao["passageiro"]["idUsuario"];
      db
          .collection("requisicao_ativa")
          .doc(idPassageiro)
          .update({"status": StatusRequisicao.A_CAMINHO});

      //Salvar requisição ativa para motorista
      String idMotorista = usuarioMotorista.idUsuario;
      db.collection("requisicao_ativa_motorista").doc(idMotorista).set({
        "id_requisicao": idRequisicao,
        "id_usuario": idMotorista,
        "status": StatusRequisicao.A_CAMINHO
      });
    });
  }

  @override
  void initState() {
    super.initState();
    //String _idRequisicao = widget.idRequisicao;

    _adicionarListenerRequisicao();
    _adicionarListenerLocalizacao();




    // _recuperarRequisicao();
  }

  _deslogarUsuario() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacementNamed(context, "/");
  }

  _escolhaMenuItem( String escolha ){
    switch( escolha ){
      case "Deslogar" :
        _deslogarUsuario();
        break;
      case "Configurações" :
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: //AppBar(
      //   title: Text("Painel corrida - "+ _mensagemStatus),
      // )
      AppBar(
              title: Text("Painel corrida - "+ _mensagemStatus),
              actions: <Widget>[
                PopupMenuButton<String>(
                  onSelected: _escolhaMenuItem,
                  itemBuilder: (context){

                    return itensMenu.map((String item){

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
