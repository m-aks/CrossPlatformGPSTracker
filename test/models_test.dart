import 'package:flutter_test/flutter_test.dart';
import 'package:ios_android_flutter/model/response_token.dart';
import 'package:ios_android_flutter/sqlite/track.dart';

void main() {

  test('Response token constructor', () async {
    var value = AuthResponse(username: "Username", token: "Token");
    expect("Username", value.username);
    expect("Token", value.token);
  });

  test('Response token from Map', () async {
    Map<String, dynamic> json = {
      'username': "Username",
      'token': "Token"
    };
    var value = AuthResponse.fromJson(json);
    expect("Username", value.username);
    expect("Token", value.token);
  });

}
