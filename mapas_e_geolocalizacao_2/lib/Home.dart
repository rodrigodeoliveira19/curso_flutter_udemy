import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Completer<GoogleMapController> _controller = Completer();

  _movimentarCamera() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(-23.562436, -46.655005),
                zoom: 16,
                tilt: 0,
                bearing: 270
            )
        )
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Mapas e Geolocalização"),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.done),
            onPressed: _movimentarCamera
        ),
        body: GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition: CameraPosition(
            target: LatLng(-23.560774, -46.657284),
            zoom: 16,
          ),
          //Constroi o mapa
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ));
  }
}
