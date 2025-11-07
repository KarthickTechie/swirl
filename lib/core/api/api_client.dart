import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiClient {
  Dio getDio() {
    Dio dio = Dio();
    dio.options.headers = {
      'token': 'U2FsdGVkX1/Wa6+JeCIOVLl8LTr8WUocMz8kIGXVbEI9Q32v7zRLrnnvAIeJIVV3',
      'deviceId': 'U2FsdGVkX180H+UTzJxvLfDRxLNCZeZK0gzxeLDg9Azi7YqYqp0KqhJkMb7DiIns',
      'userid': '4321',
    };
    dio.interceptors.add(
      PrettyDioLogger(
        responseHeader: true,
        responseBody: true,
        requestHeader: true,
        requestBody: true,
        request: true,
        compact: false,
      ),
    );
    return dio;
  }
}
