import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Mapa extends StatefulWidget {
  const Mapa({Key? key}) : super(key: key);

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  Completer<GoogleMapController> _controller = Completer();

  //Marcadores de locais no mapa
  Set<Marker> _marcadores = {};

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _exibirMarcador(LatLng latLng){
    Marker marcador = Marker(
        markerId: MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
        position: latLng,
        // infoWindow: InfoWindow(
        //     title: "Shopping Cidade São Paulo"
        // ),
        // icon: BitmapDescriptor.defaultMarkerWithHue(
        //     BitmapDescriptor.hueMagenta
        // ),
        // onTap: (){
        //   print("Shopping clicado!!");
        // }
      //rotation: 45
    );

    setState(() {
      _marcadores.add(marcador);
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(-23.563370, -46.652923),
            zoom: 16,
          ),
          //Constroi o mapa
          onMapCreated: _onMapCreated,
          onLongPress: _exibirMarcador,
          markers: _marcadores,
        ),
      ),
    );
  }
}
