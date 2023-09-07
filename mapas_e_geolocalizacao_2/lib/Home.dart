import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _posicaoCamera = CameraPosition(
      target: LatLng(-23.562436, -46.655005),
      zoom: 16,
      tilt: 0,
      bearing: 270);

  //Marcadores de locais no mapa
  Set<Marker> _marcadores = {};

  //Marcadores de areas
  Set<Polygon> _polygons = {};

  //Marcadores de linha
  Set<Polyline> _polylines = {};

  _movimentarCamera() async {
    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
        _posicaoCamera
        )
    );
  }

  _carregarMarcadores() {
    //Marcador de local
    /*Set<Marker> marcadoresLocal = {};

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
    });*/

    //Marcador de area
    /*Set<Polygon> listaPolygons = {};
    Polygon polygon1 = Polygon(
        polygonId: PolygonId("polygon1"),
        fillColor: Colors.green,
        strokeColor: Colors.red,
        strokeWidth: 20,
        points: [
          LatLng(-23.561816, -46.652044),
          LatLng(-23.563625, -46.653642),
          LatLng(-23.564786, -46.652226),
          LatLng(-23.563085, -46.650531),
        ],
        consumeTapEvents: true,
        onTap: (){
          print("clicado na área");
        },
        zIndex: 1
    );

    Polygon polygon2 = Polygon(
        polygonId: PolygonId("polygon2"),
        fillColor: Colors.purple,
        strokeColor: Colors.orange,
        strokeWidth: 20,
        points: [
          LatLng(-23.561629, -46.653031),
          LatLng(-23.565189, -46.651872),
          LatLng(-23.562032, -46.650831),
        ],
        consumeTapEvents: true,
        onTap: () {
          print("clicado na área");
        },
        zIndex: 0);

    listaPolygons.add(polygon1);
    listaPolygons.add(polygon2);

    setState(() {
      _polygons = listaPolygons;
    });*/

    Set<Polyline> listaPolylines = {};
    Polyline polyline = Polyline(
        polylineId: PolylineId("polyline"),
        color: Colors.red,
        width: 10,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
        points: [
          LatLng(-23.563645, -46.653642),
          LatLng(-23.565160, -46.651797),
          LatLng(-23.563232, -46.648020),
        ],
        consumeTapEvents: true,
        onTap: () {
          print("clicado na área");
        });

    listaPolylines.add(polyline);
    setState(() {
      _polylines = listaPolylines;
    });
  }

  _recuperarLocalizacaoAtual() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    Marker marcadorUsuario = Marker(
        markerId: MarkerId("marcador-usuario"),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: InfoWindow(
            title: "Meu local"
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueMagenta
        ),
        onTap: (){
          print("Meu local clicado!!");
        }
      //rotation: 45
    );

    setState(() {
      _marcadores.add(marcadorUsuario);
      _posicaoCamera = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 17
      );
      _movimentarCamera();
    });


    //-23.570893, -46.644995
    //-23,570893, -46,644995

    print("Ponto: localizacao atual: " + position.toString());
  }

  @override
  void initState() {
    super.initState();
    //_carregarMarcadores();
    _recuperarLocalizacaoAtual();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Mapas e Geolocalização"),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.done), onPressed: _movimentarCamera),
        body: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(-23.563370, -46.652923),
            zoom: 16,
          ),
          //Constroi o mapa
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: _marcadores,
          polygons: _polygons,
          polylines: _polylines,
        ));
  }
}
