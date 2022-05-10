import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ios_android_flutter/widgets/tracks_widget.dart';

import '../helpers/theme.dart';
import '../sqlite/provider.dart';

class RouteWidget extends StatefulWidget {
  late int trackId;

  RouteWidget({Key? key, required int trackId}) : super(key: key) {
    this.trackId = trackId;
  }

  @override
  State<RouteWidget> createState() => _RouteWidget(trackId);
}

class _RouteWidget extends State<RouteWidget> {
  int trackId;

  _RouteWidget(this.trackId);

  List<LatLng> points = <LatLng>[];

  @override
  void initState() {
    super.initState();
    DBProvider.db.getRoutesByTrackId(trackId).then((value) {
      setState(() {
        points = value.map((e) => LatLng(e.latitude, e.longitude)).toList();
      });
    });
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
        home: SafeArea(child: getVerticalEdit()) //getHorizontalEdit();
        );
  }

  Scaffold getVerticalEdit() {
    return Scaffold(
        body: Stack(
          children: points.isEmpty
              ? []
              : [
                  GoogleMap(
                      initialCameraPosition: CameraPosition(
                          target: LatLng(
                              points.first.latitude, points.first.longitude),
                          zoom: 14),
                      myLocationButtonEnabled: false,
                      myLocationEnabled: false,
                      mapType: MapType.normal,
                      polylines: {
                        Polyline(
                          polylineId: const PolylineId('overview_polyline'),
                          color: CustomColors.polyline,
                          width: 5,
                          points: points,
                        ),
                      })
                ],
        ),
        floatingActionButton: FloatingActionButton(
            heroTag: "back_to_tracks",
            backgroundColor: CustomColors.secondaryColor,
            child: Icon(Icons.arrow_back, color: CustomColors.icon),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TracksWidget(needToWrap: false)));
            }),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat);
  }
}
