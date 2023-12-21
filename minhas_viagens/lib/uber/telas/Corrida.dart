import 'dart:async';
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

class Corrida extends StatefulWidget {
  String idRequisicao;

  Corrida(this.idRequisicao);

  @override
  State<Corrida> createState() => _CorridaState();
}

class _CorridaState extends State<Corrida> {
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

      setState(() {
        _posicaoCamera = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 19);
        _exibirMarcadorPassageiro(position);
        _movimentarCamera();
        _localMotorista = position;
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

  _recuperarRequisicao() async{
    String idRequisicao = widget.idRequisicao;

    FirebaseFirestore db = FirebaseFirestore.instance;
    //Get Requisicao
    DocumentSnapshot snapshot =
    await db.collection("requisicoes").doc( idRequisicao ).get();

    _dadosRequisicao = snapshot.data() as Map<String,dynamic>;

    _adicionarListenerRequisicao();

  }

  _adicionarListenerRequisicao() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String idRequisicao = _dadosRequisicao["id"];
    await db
        .collection("requisicoes")
        .doc(idRequisicao)
        .snapshots()
        .listen((event) {
      if (event.data() != null) {
        var requisicao = event.data() as Map;
        String status = requisicao["status"];

        switch (status) {
          case StatusRequisicao.AGUARDANDO:
            _statusAguardando();
            break;
          case StatusRequisicao.A_CAMINHO:
            _statusACaminho();
            break;
          case StatusRequisicao.VIAGEM:
            break;
          case StatusRequisicao.FINALIZADA:
            break;
        }

      }
    });
  }

  _statusAguardando() {
    _alterarBotaoPrincipal("Aceitar Corrida", Color(0xff1ebbd8), () {
      _aceitarCorrida();
    });
  }

  _statusACaminho() {
    _alterarBotaoPrincipal("Motorista a caminho", Color(0xff1ebbd8), (){});

    double latitudePassageiro = _dadosRequisicao["passageiro"]["latitude"];
    double longitudePassageiro = _dadosRequisicao["passageiro"]["longitude"];

    double latitudeMotorista = _dadosRequisicao["motorista"]["latitude"];
    double longitudeMotorista = _dadosRequisicao["motorista"]["longitude"];

    _exibirDoisMarcadores(LatLng(latitudePassageiro, longitudePassageiro),
        LatLng(latitudeMotorista, longitudeMotorista));
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
      _posicaoCamera = CameraPosition(target: latLngMotorista, zoom: 25);
      _movimentarCamera();
    });
  }

  _aceitarCorrida() async{
    //Recuperar dados do Motorista
    Usuario usuarioMotorista = await UsuarioFirebase.getUsuarioLogado();
    usuarioMotorista.latitude = _localMotorista.latitude;
    usuarioMotorista.longitude = _localMotorista.longitude;

    FirebaseFirestore db = FirebaseFirestore.instance;
    String idRequisicao = _dadosRequisicao["id"];

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
    _adicionarListenerLocalizacao();

    _recuperarRequisicao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Painel corrida"),
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
