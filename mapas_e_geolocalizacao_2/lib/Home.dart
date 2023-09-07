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

  //Marcadores de locais no mapa
  Set<Marker> _marcadores = {};

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

  _carregarMarcadores(){

    Set<Marker> marcadoresLocal = {};

    Marker marcadorShopping = Marker(
        markerId: MarkerId("marcador-shopping"),
        position: LatLng(-23.563371, -46.652924),
        infoWindow: InfoWindow(
            title: "Shopping Cidade São Paulo"
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueMagenta
        ),
        onTap: (){
          print("Shopping clicado!!");
        }
      //rotation: 45
    );

    Marker marcadorCartorio = Marker(
        markerId: MarkerId("marcador-cartorio"),
        position: LatLng(-23.56122591994096, -46.65680722164037),
        infoWindow: InfoWindow(
            title: "12 Cartório de notas"
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue
        ),
        onTap: (){
          print("Cartório clicado!!");
        }
    );

    marcadoresLocal.add( marcadorShopping );
    marcadoresLocal.add( marcadorCartorio );

    setState(() {
      _marcadores = marcadoresLocal;
    });
  }

  @override
  void initState() {
    super.initState();
    _carregarMarcadores();
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
            target: LatLng(-23.563370, -46.652923),
            zoom: 16,
          ),
          //Constroi o mapa
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: _marcadores,
        ));
  }
}
