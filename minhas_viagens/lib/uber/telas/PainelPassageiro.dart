import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class PainelPassageiro extends StatefulWidget {
  const PainelPassageiro({Key? key}) : super(key: key);

  @override
  State<PainelPassageiro> createState() => _PainelPassageiroState();
}

class _PainelPassageiroState extends State<PainelPassageiro> {

  List<String> itensMenu = [
    "Configurações", "Deslogar"
  ];
  Completer<GoogleMapController> _mapController = Completer();
  CameraPosition _posicaoCamera = CameraPosition(
    target: LatLng(-23.563370, -46.652923),
    zoom: 16,
  );

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

  _onMapCreated(GoogleMapController mapController) {
    _mapController.complete(mapController);
  }

  _adicionarListenerLocalizacao() async{
    LocationPermission permission;
    permission = await Geolocator.requestPermission();

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    StreamSubscription<Position> positionStream =
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      print(position == null
          ? 'Local: Unknown'
          : 'Posicao atual: ${position.latitude.toString()}, ${position.longitude.toString()}');

      setState(() {
        _posicaoCamera = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 16
        );
        _movimentarCamera();
      });
    });
  }

  _movimentarCamera() async {
    GoogleMapController googleMapController = await _mapController.future;
    googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
            _posicaoCamera
        )
    );
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
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _posicaoCamera,
          //Constroi o mapa
          onMapCreated: _onMapCreated,
          //onLongPress: _adicionarMarcador,
          //markers: _marcadores,
        ),
      ),
    );
  }
}
