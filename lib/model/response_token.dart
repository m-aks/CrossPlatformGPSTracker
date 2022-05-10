import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class AuthResponse {
  late String username;
  late String token;

  AuthResponse({required this.username, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$ResponseTokenFromJson(json);
}

AuthResponse _$ResponseTokenFromJson(Map<String, dynamic> json) {
  return AuthResponse(
      username: json['username'].toString(), token: json['token'].toString());
}
