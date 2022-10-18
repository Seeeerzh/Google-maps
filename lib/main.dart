import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemaps/locationService.dart';
import 'package:location/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {

final Completer<GoogleMapController> myController = Completer();

  TextEditingController _searchcontroller = TextEditingController();

final Location _location = Location();

LocationData _curLoc = LocationData.fromMap({"latitude": 0.0, "longitude": 0.0});

final CameraPosition _initialCameraPosition = const CameraPosition(
      zoom: 5, tilt: 0, bearing: 0, target: LatLng(39.283889, 35.241667));

late Future<bool> _locationFuture;

static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

static final Marker _kGooglePlexMarker = Marker(
    markerId: MarkerId('_kGooglePlex'),
    infoWindow: InfoWindow(title: 'Google Plex'),
    icon: BitmapDescriptor.defaultMarker,
    position:LatLng(37.42796133580664, -122.085749655962), 
    );

 static final Marker _kLakeMarker = Marker(
    markerId: MarkerId('_kLakeMarker'),
    infoWindow: InfoWindow(title: 'Lake'),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    position:LatLng(37.43296265331129, -122.08832357078792),
    );

  @override
  void initState() {
    _locationFuture = _checkLocationPermission();
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title:  Text("Experiment")),
      body:
      FutureBuilder<bool>(
        future: _locationFuture,
        builder: (context, AsyncSnapshot<bool> snapLoc) {
        return  Stack(
        children: [
          GoogleMap(
myLocationEnabled:snapLoc.hasData && snapLoc.data!,
myLocationButtonEnabled:false,
zoomControlsEnabled:false,
compassEnabled: false,
tiltGesturesEnabled:false,
mapToolbarEnabled:false,
buildingsEnabled: false,
initialCameraPosition:_initialCameraPosition,
markers: Set<Marker>.of([Marker(
    markerId: MarkerId('_kGooglePlex'),
    infoWindow: InfoWindow(title: 'Google Plex'),
    icon: BitmapDescriptor.defaultMarker,
    position:LatLng(37.42796133580664, -122.085749655962), 
    ),] ),
onMapCreated:(theController) {myController.complete(theController);},onTap: (loc) {},),
         /* Row(children: [
            Expanded(child: TextFormField(
              controller: _searchcontroller,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(hintText: 'Search'),
              onChanged: (value){
                print(value);
              },
            )),
            
            ],),*/
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
Expanded(child: TextFormField(
              controller: _searchcontroller,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(hintText: 'Search'),
              onChanged: (value){
                print(value);
              },
            )),                      
IconButton(
                    icon: const Icon(Icons.search),
                    color: Colors.black,
               
                    onPressed: () async {
                      var place = await LocationService().getPlace(_searchcontroller.text.toString());
                      _goToPlace(place);
                    },
                  ),
IconButton(
                    icon: const Icon(Icons.clear_all_outlined),
                    color: Colors.black,
                    
                    onPressed: () {
                     _updateCamera(LatLng(37.42796133580664, -122.085749655962),);
                    },
                  ),
IconButton(
                    icon: const Icon(Icons.location_city),
                    color: Colors.black,
                   
                    onPressed: () {
                      if (snapLoc.hasData && snapLoc.data!) {
                            _updateCamera(LatLng(
                              _curLoc.latitude!,
                              _curLoc.longitude!,
                            ));
                          } else {
                            setState(() {
                              _locationFuture = _checkLocationPermission();
                            });
                          }
                    },
                  ),
                  ],)
                ],

              ),
            ),
          
        ],
      );
                }),
      
      
    );
  }

  Future<void> _goToPlace(Map<String, dynamic> place) async {
    final double lat = place['geometry']['location']['lat'];
    final double lng = place['geometry']['location']['lng'];
    final GoogleMapController controller = await myController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(lat, lng), zoom: 12,),
    ));
  }
  

  Future<void> _updateCamera(LatLng pos) async {
    CameraPosition cPosition = CameraPosition(
      zoom: 15,
      tilt: 0,
      bearing: 0,
      target: LatLng(pos.latitude + 0.003, pos.longitude),
    );
    final GoogleMapController controller = await myController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
  }


  Future<bool> _checkLocationPermission() async {
    try {
      PermissionStatus _permissionGranted = await _location.hasPermission();
      if (_permissionGranted == PermissionStatus.granted) {
        bool _serviceEnabled = await _location.serviceEnabled();
        if (!_serviceEnabled) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => SimpleDialog(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    title: Center(child: Text("Allow location")),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                                elevation: 5,
                                primary: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                )),
                            child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.25,
                                child: Center(
                                    child: Text("Skip"))),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              _serviceEnabled = await _location
                                  .requestService()
                                  .whenComplete(() {
                                setState(() {
                                  _locationFuture = _checkLocationPermission();
                                });
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                elevation: 5,
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                )),
                            child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.25,
                                child:
                                    Center(child: Text("Ok"))),
                          ),
                        ],
                      ),
                    ],
                  ));
          return false;
        } else {
          await _location.changeSettings(accuracy: LocationAccuracy.high);
          _location.onLocationChanged.listen((LocationData cLoc) {
            //_scooterManager.disposeListen();
            /*_scooterManager = ScooterManager(
        Me.me,
        pX: _curLoc.latitude!,
        pY: _curLoc.longitude!,
      );*/
            _curLoc = cLoc;
          });
          return true;
        }
      } else {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => SimpleDialog(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  title: Center(child: Text("Allow location")),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                              elevation: 5,
                              primary: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              )),
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child:
                                  Center(child: Text("Skip"))),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            _permissionGranted = await _location
                                .requestPermission()
                                .whenComplete(() {
                              setState(() {
                                _locationFuture = _checkLocationPermission();
                              });
                            });
                          },
                          style: ElevatedButton.styleFrom(
                              elevation: 5,
                             backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              )),
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: Center(child: Text("OK"))),
                        ),
                      ],
                    ),
                  ],
                ));
        return false;
      }
    } finally {
      if (_curLoc.latitude != 39.283889 && _curLoc.longitude != 35.241667) {
        _updateCamera(LatLng(
          _curLoc.latitude!,
          _curLoc.longitude!,
        ));


      }

    }
    
  }
}