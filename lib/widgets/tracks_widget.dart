import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ios_android_flutter/sqlite/provider.dart';
import 'package:ios_android_flutter/widgets/route_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/theme.dart';
import '../sqlite/track.dart';
import '../sqlite/user.dart';
import '../utils/helper.dart';
import 'login_widget.dart';
import 'map_widget.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  Locale? locale;
  bool localeLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchLocale().then((locale) {
      setState(() {
        localeLoaded = true;
        this.locale = locale;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (localeLoaded == false) {
      return const CircularProgressIndicator();
    } else {
      return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppLocalizations.of(context)?.appName ?? '',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            locale ??= deviceLocale!;
            return locale;
          },
          theme:
              ThemeData(fontFamily: 'sans-serif-light', errorColor: Colors.red),
          home: TracksWidget(needToWrap: false));
    }
  }

  _fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('languageCode') == null) {
      return null;
    }
    return Locale(
        prefs.getString('languageCode')!, prefs.getString('countryCode'));
  }
}

class TracksWidget extends StatefulWidget {
  bool needToWrap = true;

  TracksWidget({Key? key, required this.needToWrap}) : super(key: key);

  @override
  State<TracksWidget> createState() => _TracksWidget(needToWrap);
}

class _TracksWidget extends State<TracksWidget> {
  bool needToWrap = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _TracksWidget(this.needToWrap);

  List<Track> tracks = <Track>[];

  @override
  void initState() {
    super.initState();
    DBProvider.db.getTracks().then((value) {
      setState(() {
        tracks = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: needToWrap
            ? MaterialApp(
                debugShowCheckedModeBanner: false,
                title: AppLocalizations.of(context)?.appName ?? '',
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                theme: ThemeData(
                    fontFamily: 'sans-serif-light', errorColor: Colors.red),
                home: getTracksFragment())
            : getTracksFragment());
  }

  Scaffold getTracksFragment() {
    return Scaffold(
        body: Scaffold(
            body: OrientationBuilder(builder: (context, orientation) {
              return orientation == Orientation.portrait
                  ? ListView.builder(
                      itemCount: tracks.length,
                      itemBuilder: (BuildContext context, int index) {
                        return getCard(tracks[index]);
                      },
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio:
                              MediaQuery.of(context).size.height * 0.0044),
                      itemCount: tracks.length,
                      itemBuilder: (BuildContext context, int index) {
                        return getCard(tracks[index]);
                      },
                    );
            }),
            floatingActionButton: FloatingActionButton(
                heroTag: "start",
                backgroundColor: CustomColors.secondaryColor,
                child: Icon(Icons.play_arrow, color: CustomColors.icon),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MapWidget()));
                }),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endFloat),
        floatingActionButton: FloatingActionButton(
            heroTag: "logout",
            backgroundColor: CustomColors.secondaryColor,
            child: Icon(Icons.arrow_back, color: CustomColors.icon),
            onPressed: logout),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat);
  }

  InkWell getCard(Track track) {
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
                      Row(
                        children: [
                          Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Text(
                                  (AppLocalizations.of(context)?.date ?? '') +
                                      Helper.fullDateToString(track.date),
                                  style: const TextStyle(fontSize: 24)))
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Text(
                                  (AppLocalizations.of(context)?.time ?? '') + Helper.getTimeFromInt(track.time),
                                  style: const TextStyle(fontSize: 20)))
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Text(
                                  (AppLocalizations.of(context)?.distance ?? '') +
                                      Helper.distanceUnits(track.distance),
                                  style: const TextStyle(fontSize: 20)))
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Text(
                                  (AppLocalizations.of(context)?.avgSpeed ?? '') +
                                      Helper.toFixed(track.averageSpeed)
                                          .toString() +
                                      (AppLocalizations.of(context)?.kmh ?? ''),
                                  style: const TextStyle(fontSize: 20)))
                        ],
                      ),
                      TextButton(
                          onPressed: () {
                            getRoute(track.id!);
                          },
                          child: Text(AppLocalizations.of(context)?.route ?? ''))
                    ]))));
  }

  void getRoute(int trackId) async {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => RouteWidget(trackId: trackId)));
  }

  void logout() async {
    User? user = await DBProvider.db.getActiveUser();
    if (user != null) {
      user.active = 0;
      DBProvider.db.updateUser(user);
      DBProvider.userId = null;
    }
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginWidget()));
  }
}
