import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ios_android_flutter/widgets/login_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  Locale? locale;
  bool localeLoaded = false;

  @override
  void initState() {
    super.initState();
    fetchLocale().then((locale) {
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
          theme:
              ThemeData(fontFamily: 'sans-serif-light', errorColor: Colors.red),
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            locale ??= deviceLocale!;
            return locale;
          },
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SafeArea(child: LoginWidget()));
    }
  }

  fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('languageCode') == null) {
      return null;
    }
    return Locale(
        prefs.getString('languageCode')!, prefs.getString('countryCode'));
  }
}
