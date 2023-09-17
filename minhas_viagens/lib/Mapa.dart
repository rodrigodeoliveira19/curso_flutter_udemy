import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Mapa extends StatefulWidget {
  const Mapa({Key? key}) : super(key: key);

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _posicaoCamera = CameraPosition(
    target: LatLng(-23.563370, -46.652923),
    zoom: 16,
  );

  //Marcadores de locais no mapa
  Set<Marker> _marcadores = {};

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _adicionarMarcador(LatLng latLng) async{

    List<Placemark> placemarks = await placemarkFromCoordinates
      (latLng.latitude, latLng.longitude);

    if( placemarks != null && placemarks.length > 0 ) {
      Placemark endereco = placemarks[0];

      var rua = endereco.thoroughfare.toString();

      Marker marcador = Marker(
          markerId: MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
          position: latLng,
        infoWindow: InfoWindow(
          title: rua
        )
      );

      setState(() {
        _marcadores.add(marcador);
        _salvarLocalizacaoNoFirebase(rua,latLng); 
      });
    }

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
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
            _posicaoCamera
        )
    );
  }

  _salvarLocalizacaoNoFirebase(String localizacao, LatLng latLng) async{
    //Inicializar Firebase
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    Map<String,dynamic> viagens = Map();
    viagens['localizacao'] = localizacao;
    viagens['latitude'] = latLng.latitude;
    viagens['longitude'] = latLng.longitude;

    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("viagens")
        .add(viagens);
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
        backgroundColor: Colors.deepOrange,
      ),
      body: Container(
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _posicaoCamera,
          //Constroi o mapa
          onMapCreated: _onMapCreated,
          onLongPress: _adicionarMarcador,
          markers: _marcadores,
        ),
      ),
    );
  }
}
