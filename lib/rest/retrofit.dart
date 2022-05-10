import 'package:dio/dio.dart';

import '../model/response_token.dart';
import 'apis.dart';

part 'retrofit.g.dart';

abstract class ApiRequest {

  factory ApiRequest(Dio dio, {required String baseUrl}) = _ApiRequest;

  AuthResponse login(String login, String password);

  AuthResponse register(String login, String firstname,
      String lastname, String email, String password);

  bool check(String token);
}
