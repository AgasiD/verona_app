import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:verona_app/helpers/helpers.dart';
import 'package:location/location.dart';

import 'custom_widgets.dart';

class MapCoordenates extends StatelessWidget {
  const MapCoordenates({Key? key}) : super(key: key);
  static final routeName = 'MapCoordenates';

  @override
  Widget build(BuildContext context) {
    double? latitud = null, longitud = null;

    if (ModalRoute.of(context)?.settings.arguments != null) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map;
      latitud = arguments['latitud'];
      longitud = arguments['longitud'];
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: [],
            title: Text(
              'Seleccionar ubicación',
              style: TextStyle(color: Helper.brandColors[8]),
            ),
            backgroundColor: Helper.brandColors[2],
            shadowColor: Colors.transparent),
        extendBodyBehindAppBar: true,
        body: CustomMap(latitud: latitud, longitud: longitud),
      ),
    );
  }
}

class CustomMap extends StatefulWidget {
  CustomMap({Key? key, this.latitud, this.longitud}) : super(key: key);
  double? latitud, longitud;

  @override
  State<CustomMap> createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {


  late CameraPosition posicionInicial;

  var markers = <Marker>[];
  bool repitio = false;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: setInitialPosition(context,widget.latitud, widget.longitud),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          posicionInicial = CameraPosition(
            target: snapshot.data as LatLng,
            zoom: 15.0,
          );
          if (widget.latitud != null && !repitio) {
            markers = [
              Marker(
                  markerId: MarkerId('anyUniqueId'),
                  position: snapshot.data as LatLng,
                  infoWindow: InfoWindow(title: ''))
            ];
          }
          repitio = true;
          return Container(
            child: Stack(children: [
              Custom_Map(
                  setMarker: setMarker,
                  markers: markers,
                  posicionInicial: posicionInicial,
                  ),
              Positioned(
                left: MediaQuery.of(context).size.width * .5 - 100,
                bottom: 25,
                child: MainButton(
                  width: 150,
                  height: 20,
                  color: Helper.brandColors[8],
                  onPressed: () => Navigator.pop(
                      context, markers.length > 0 ? markers[0] : null),
                  text: 'Guardar ubicación',
                  fontSize: 15,
                ),
              )
            ]),
          );
        });
  }

  setMarker(LatLng latlang) {
    markers = [
      Marker(
          markerId: MarkerId('anyUniqueId'),
          position: latlang,
          infoWindow: InfoWindow(title: ''))
    ];
    setState(() {});
  }
}

setInitialPosition(context, double? latitud, double? longitud) async {
  if (longitud != null) {
    return LatLng(latitud!, longitud!);
  }
  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    Platform.isAndroid ? await openAlertDialogReturn(context, 'Se require utilzar la ubicación para inicilizar la camara del mapa') : false;
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return LatLng(0, 0);
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
        Platform.isAndroid ? await openAlertDialogReturn(context, 'Se require utilzar la ubicación para inicilizar la camara del mapa') : false;

    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return LatLng(0, 0);
    }
  }

  _locationData = await location.getLocation();
  return LatLng(_locationData.latitude!, _locationData.longitude!);
}

class Custom_Map extends StatefulWidget {
  Custom_Map({
    Key? key,
    required this.setMarker,
    required this.markers,
    required this.posicionInicial,
  })  :super(key: key);
  Function(LatLng) setMarker;
  final List<Marker> markers;
  final CameraPosition posicionInicial;

  @override
  State<Custom_Map> createState() => _Custom_MapState();
}

class _Custom_MapState extends State<Custom_Map> {

    Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {


return GoogleMap(
  myLocationButtonEnabled: true,
  markers: widget.markers.toSet(),
  onLongPress: (a) {
    widget.setMarker(a);
  },
  myLocationEnabled: true,
  mapType: MapType.hybrid,
  initialCameraPosition: widget.posicionInicial,
  key: ValueKey('uniqueey'),
onMapCreated: (GoogleMapController controller) {
        // _controller.complete(controller);
      },
);


  }
  @override
void dispose() {
  _disposeController();
  super.dispose();
}

  Future<void> _disposeController() async {
  final GoogleMapController controller = await _controller.future;
  controller.dispose();
}
}
