import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:verona_app/helpers/helpers.dart';

class MapCoordenates extends StatelessWidget {
  const MapCoordenates({Key? key}) : super(key: key);
  static final routeName = 'MapCoordenates';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    print(width);
    final height = MediaQuery.of(context).size.height;
    print(height);
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          actions: [],
          title: Text('Seleccionar ubicación', style: TextStyle(color: Helper.brandColors[3]),),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent),
      extendBodyBehindAppBar: true,
      body: CustomMap(),
    );
  }
}

class CustomMap extends StatelessWidget {
   CustomMap({Key? key}) : super(key: key);
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();


  @override
  Widget build(BuildContext context) {

//  final map = GoogleMap(
//   myLocationButtonEnabled: true,
  
//   onLongPress: (a) => print('longrrees'),
//               // myLocationEnabled: true,
//               // myLocationButtonEnabled: true,
//                       mapType: MapType.hybrid,

//               initialCameraPosition: CameraPosition(
//                 target: LatLng(-34.605940,58.486935),
//                 zoom: 15.0,
//               ),
              
//               key: ValueKey('uniqueey'),
//               onMapCreated: (GoogleMapController controller) {
//               _controller.complete(controller);
//         },
//               markers: {
//                 Marker(
//                     markerId: MarkerId('anyUniqueId'),
//                     position: LatLng(-34.605940,58.486935),
//                     infoWindow: InfoWindow(title: ''))
//               },
//             );



    final width = MediaQuery.of(context).size.width;
    print(width);
    final height = MediaQuery.of(context).size.height;
    print(height);
    return Container(
      
      // child: map
      // Stack(children: [
      //   ,
      //   Center(
      //       child: Icon(FontAwesomeIcons.houseChimney, color: Helper.brandColors[8]),
      //   )
      // ]),
    );

    
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                target: LatLng(-34.605940,58.486935),
                zoom: 15.0,
              ),));
  }
}
