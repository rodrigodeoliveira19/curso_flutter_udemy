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
import '../util/StatusRequisicao.dart';

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

      setState(() {
        _posicaoCamera = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 19
        );
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

  void _exibirMarcadorPassageiro(Position position) async{
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        "imagens/uber/passageiro.png"
    ).then((BitmapDescriptor icon) {

      Marker marcadorPassageiro = Marker(
          markerId: MarkerId("${position.latitude} - "
              "${position.longitude} - "
              "marcador-passageiro"),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(
              title: "Meu Local"
          ),
          icon: icon,
          onTap: () {
            print("Cartório clicado!!");
          }
      );

      setState(() {
        _marcadores.add(marcadorPassageiro);
      });

    });
  }

  void _chamarUber() async{
    String enderecoDestino = _controllerDestino.text;
    if(enderecoDestino.isNotEmpty){

      List<Location> locations = await locationFromAddress(
          _controllerDestino.text
      );
      print("Endereços2: "+locations.toString());

      if( locations != null && locations.length > 0 ){

        //Obtendo o endereço a partir da latitude e longitude.
        List<Placemark> placemarks = await placemarkFromCoordinates
          (locations[0].latitude, locations[0].longitude);

        if( placemarks != null && placemarks.length > 0 ){

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
          enderecoConfirmacao += "\n Rua: " + destino.rua + ", " + destino.numero ;
          enderecoConfirmacao += "\n Bairro: " + destino.bairro ;
          enderecoConfirmacao += "\n Cep: " + destino.cep ;

          showDialog(
              context: context,
              builder: (contex){
                return AlertDialog(
                  title: Text("Confirmação do endereço"),
                  content: Text(enderecoConfirmacao),
                  contentPadding: EdgeInsets.all(16),
                  actions: <Widget>[
                    ElevatedButton(
                      child: Text("Cancelar", style: TextStyle(color: Colors.red),),
                      onPressed: () => Navigator.pop(contex),
                    ),
                    ElevatedButton(
                      child: Text("Confirmar", style: TextStyle(color: Colors.green),),
                      onPressed: (){

                        //salvar requisicao
                        _salvarRequisicao(destino);

                        Navigator.pop(contex);

                      },
                    )
                  ],
                );
              }
          );

        }
      }

    }
  }

  Future<void> _salvarRequisicao(Destino destino) async {
    Usuario usuario = await UsuarioFirebase.getUsuarioLogado();

    Requisicao requisicao = Requisicao();
    requisicao.destino = destino;
    requisicao.status = StatusRequisicao.AGUARDANDO;
    requisicao.passageiro = usuario;

    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("requisicoes").add(requisicao.toMap());
  }

  @override
  void initState() {
    super.initState();
    _adicionarListenerLocalizacao();
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
                      contentPadding: EdgeInsets.only(left: 15, top: 16)),
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
                      contentPadding: EdgeInsets.only(left: 15, top: 16)),
                ),
              ),
            ),
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
                onPressed: _chamarUber,
                child: Text(
                  "Chamar uber",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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
