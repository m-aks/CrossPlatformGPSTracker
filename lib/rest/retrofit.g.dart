part of 'retrofit.dart';

class _ApiRequest implements ApiRequest {
  final Dio dio;

  String baseUrl;

  _ApiRequest(this.dio, {required this.baseUrl}) {
    ArgumentError.checkNotNull(dio, 'dio');
  }

  @override
  login(String login, String password) async {
    final data = <String, dynamic>{};
    data.putIfAbsent("username", () => login);
    data.putIfAbsent("password", () => password);
    var options = Options(
        receiveTimeout: 1000,
        sendTimeout: 1000,
        method: 'POST',
        validateStatus: (status) => true);
    final result = await dio.request('$baseUrl${Apis.login}',
        options: options, data: data);
    if (result.statusCode == 200) {
      return AuthResponse.fromJson(result.data);
    } else {
      return null;
    }
  }

  @override
  register(String login, String firstname, String lastname, String email,
      String password) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final data = <String, dynamic>{};
    data.putIfAbsent("username", () => login);
    data.putIfAbsent("firstName", () => firstname);
    data.putIfAbsent("lastName", () => lastname);
    data.putIfAbsent("email", () => email);
    data.putIfAbsent("password", () => password);
    var options = Options(
        receiveTimeout: 1000,
        sendTimeout: 1000,
        method: 'POST',
        headers: <String, dynamic>{},
        extra: extra,
        validateStatus: (status) => true);
    final result = await dio.request('$baseUrl${Apis.register}',
        queryParameters: queryParameters, options: options, data: data);
    if (result.statusCode == 200) {
      return AuthResponse.fromJson(result.data);
    } else {
      return null;
    }
  }

  @override
  check(String token) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final data = <String, dynamic>{};
    final headers = <String, dynamic>{};
    headers.putIfAbsent("Authorization", () => "Bearer_$token");
    var options = Options(
        receiveTimeout: 1000,
        sendTimeout: 1000,
        method: 'GET',
        headers: headers,
        extra: extra,
        validateStatus: (status) => true);
    final result = await dio.request('$baseUrl${Apis.check}',
        queryParameters: queryParameters, options: options, data: data);
    return result.statusCode == 200;
  }
}
