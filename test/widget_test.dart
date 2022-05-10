import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ios_android_flutter/widgets/login_widget.dart';
import 'package:ios_android_flutter/widgets/map_widget.dart';
import 'package:ios_android_flutter/widgets/tracks_widget.dart';

void main() {

  testWidgets("test auth interface to Register screen click", (WidgetTester tester) async {
    var toRegisterScreen = find.byKey(const ValueKey("toRegister"));

    await tester.pumpWidget(const MaterialApp(
        locale: Locale('en'),
        home: LoginWidget()));
    await tester.pump();
    await tester.tap(toRegisterScreen);
    await tester.pump();

    expect(find.byType(TextField), findsNWidgets(5));
    expect(find.byType(ElevatedButton), findsNWidgets(1));
    expect(find.byType(TextButton), findsNWidgets(1));
  });

  testWidgets("test main interface", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        locale: Locale('en'),
        home: MapWidget()));
    await tester.pump();
    expect(find.byType(GoogleMap), findsNWidgets(1));
    expect(find.byType(Card), findsNWidgets(4));
  });
}
