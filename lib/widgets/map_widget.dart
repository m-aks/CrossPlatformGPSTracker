import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ios_android_flutter/sqlite/route.dart';
import 'package:ios_android_flutter/sqlite/track.dart';
import 'package:ios_android_flutter/widgets/tracks_widget.dart';
import 'package:location/location.dart' as g;

import '../helpers/theme.dart';
import '../sqlite/provider.dart';
import '../utils/helper.dart';

class MapWidget extends StatefulWidget {
  MapWidget({Key? key}) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidget();
}

class _MapWidget extends State<MapWidget> {
  _MapWidget();

  int counter = 0;
  double speed = 0;
  double averageSpeed = 0;
  double distance = 0;
  int time = 0;
  bool isTracking = true;
  List<LatLng> points = <LatLng>[];
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController googleMapController;
  late g.Location location;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        time++;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppLocalizations.of(context)?.appName ?? '',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme:
            ThemeData(fontFamily: 'sans-serif-light', errorColor: Colors.red),
        home:
            SafeArea(child: OrientationBuilder(builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? getVerticalEdit()
              : getHorizontalEdit();
        })));
  }

  Scaffold getVerticalEdit() {
    return Scaffold(
      body: ListView(children: [
        Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              height: 500,
              width: 400,
              child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                      target: LatLng(0, 0),
                      zoom: 14),
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  mapType: MapType.normal,
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('overview_polyline'),
                      color: CustomColors.polyline,
                      width: 5,
                      points: points,
                    ),
                  },
                  onMapCreated: (GoogleMapController controller) {
                    startTracking(controller);
                  }),
            )
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            getCard(AppLocalizations.of(context)?.distance ?? '',
                Helper.distanceUnits(distance.toInt())),
            getCard(AppLocalizations.of(context)?.avgSpeed ?? '',
                averageSpeed.toString())
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            getCard(
                AppLocalizations.of(context)?.speed ?? '', speed.toString()),
            getCard(AppLocalizations.of(context)?.time ?? '',
                Helper.getTimeFromInt(time))
          ])
        ])
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: stopTracking,
        child: Icon(Icons.stop, color: CustomColors.icon),
        backgroundColor: CustomColors.secondaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Scaffold getHorizontalEdit() {
    return Scaffold(
      body: ListView(children: [
        Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              height: 300,
              width: 670,
              child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                      target: LatLng(0, 0),
                      zoom: 14),
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  mapType: MapType.normal,
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('overview_polyline'),
                      color: CustomColors.polyline,
                      width: 5,
                      points: points,
                    ),
                  },
                  onMapCreated: (GoogleMapController controller) {
                    startTracking(controller);
                  }),
            )
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            getCard(
                AppLocalizations.of(context)?.speed ?? '', speed.toString()),
            getCard(AppLocalizations.of(context)?.time ?? '',
                Helper.getTimeFromInt(time)),
            getCard(AppLocalizations.of(context)?.distance ?? '',
                Helper.distanceUnits(distance.toInt())),
            getCard(AppLocalizations.of(context)?.avgSpeed ?? '',
                averageSpeed.toString())
          ])
        ])
      ]),
      floatingActionButton: FloatingActionButton(
        key: Key("stop"),
        onPressed: stopTracking,
        child: Icon(Icons.stop, color: CustomColors.icon),
        backgroundColor: CustomColors.secondaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  InkWell getCard(String key, String value) {
    return InkWell(
        splashColor: CustomColors.colorHighlight,
        child: Card(
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Text(key))
                      ]),
                      Row(children: [
                        Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Text(value))
                      ])
                    ]))));
  }

  void startTracking(GoogleMapController controller) async {
    _controllerGoogleMap.complete(controller);
    googleMapController = controller;
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location Not Available');
      }
    }
    location = g.Location();
    var currPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    CameraPosition cameraPosition = CameraPosition(
        target: LatLng(currPos.latitude, currPos.longitude), zoom: 14);
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    location.onLocationChanged
        .takeWhile((element) => isTracking)
        .timeout(const Duration(seconds: 5))
        .listen((locationData) async {
      LatLng latLng = LatLng(locationData.latitude!, locationData.longitude!);
      if (points.isEmpty) {
        points.add(latLng);
      } else if (points.last != latLng) {
        double distance = Geolocator.distanceBetween(
            locationData.latitude!,
            locationData.longitude!,
            points.last.latitude,
            points.last.longitude);
        if (distance > 1) {
          speed = Helper.toFixed(locationData.speed!);
          averageSpeed =
              Helper.toFixed(((averageSpeed * counter++) + speed) / counter);
          this.distance += distance;
          double bearing = Geolocator.bearingBetween(
              points.last.latitude,
              points.last.longitude,
              locationData.latitude!,
              locationData.longitude!);
          googleMapController.moveCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  bearing: bearing, target: points.last, tilt: 20, zoom: 18)));
          points.add(latLng);
          setState(() {});
        }
      }
    });
  }

  void stopTracking() async {
    isTracking = false;
    timer.cancel();
    setState(() {});
    int trackId = await DBProvider.db.newTrack(Track(
        date: DateTime.now().millisecondsSinceEpoch,
        distance: distance.toInt(),
        averageSpeed: averageSpeed,
        time: time,
        userId: DBProvider.userId!));
    for (var element in points) {
      DBProvider.db.newRoute(Rout(
          latitude: element.latitude,
          longitude: element.longitude,
          trackId: trackId));
    }
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => TracksWidget(needToWrap: false)));
  }
}
