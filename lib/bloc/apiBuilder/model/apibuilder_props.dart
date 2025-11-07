import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class ApiModel extends Equatable {
  final String apiName;
  final String apiEndpoint;
  final String apiMethodName;
  final String httpMethod;
  final List<Header> headers;
  final RequestObject requestKeys;
  final dynamic responses;

  const ApiModel({
    required this.apiName,
    required this.apiEndpoint,
    required this.apiMethodName,
    required this.httpMethod,
    this.headers = const [],
    required this.requestKeys,
    this.responses,
  });

  // ======= JSON Deserialization =======
  // factory ApiModel.fromJson(Map<String, dynamic> json) {
  //   return ApiModel(
  //     apiName: json['apiName'] ?? '',
  //     apiEndpoint: json['apiEndpoint'] ?? '',
  //     apiMethodName: json['apiMethodName'] ?? '',
  //     httpMethod: json['httpMethod'] ?? '',
  //     headers:
  //         (json['headers'] as List<dynamic>?)
  //             ?.map((e) => Header.fromJson(e))
  //             .toList() ??
  //         [],
  //     requestKeys:
  //         json['requestKeys'] != null
  //             ? RequestObject.fromJson(
  //               Map<String, dynamic>.from(json['requestKeys']),
  //             )
  //             : const RequestObject({}),
  //     responses: json['responses'] != null
  //         ? ApiResponse.fromJson(json['responses'])
  //         : null,
  //   );
  // }

  // ======= JSON Serialization =======
  String toJson() => json.encode(toMap());

  // ======= CopyWith =======
  ApiModel copyWith({
    String? apiName,
    String? apiEndpoint,
    String? apiMethodName,
    String? httpMethod,
    List<Header>? headers,
    RequestObject? requestKeys,
    dynamic responses,
  }) {
    return ApiModel(
      apiName: apiName ?? this.apiName,
      apiEndpoint: apiEndpoint ?? this.apiEndpoint,
      apiMethodName: apiMethodName ?? this.apiMethodName,
      httpMethod: httpMethod ?? this.httpMethod,
      headers: headers ?? this.headers,
      requestKeys: requestKeys ?? this.requestKeys,
      responses: responses ?? this.responses,
    );
  }

  @override
  List<Object?> get props {
    return [
      apiName,
      apiEndpoint,
      apiMethodName,
      httpMethod,
      headers,
      requestKeys,
      responses,
    ];
  }

  Map<String, dynamic> toMap() {
    return {
      'apiName': apiName,
      'apiEndpoint': apiEndpoint,
      'apiMethodName': apiMethodName,
      'httpMethod': httpMethod,
      'headers': headers.map((x) => x.toMap()).toList(),
      'requestKeys': requestKeys.toMap(),
      'responses': responses,
    };
  }

  factory ApiModel.fromMap(Map<String, dynamic> map) {
    return ApiModel(
      apiName: map['apiName'] ?? '',
      apiEndpoint: map['apiEndpoint'] ?? '',
      apiMethodName: map['apiMethodName'] ?? '',
      httpMethod: map['httpMethod'] ?? '',
      headers: List<Header>.from(map['headers']?.map((x) => Header.fromMap(x))),
      requestKeys: RequestObject.fromMap(map['requestKeys']),
      responses: map['responses'] ?? '',
    );
  }

  factory ApiModel.fromJson(String source) =>
      ApiModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ApiModel(apiName: $apiName, apiEndpoint: $apiEndpoint, apiMethodName: $apiMethodName, httpMethod: $httpMethod, headers: $headers, requestKeys: $requestKeys, responses: $responses)';
  }
}

// ======= Header Class =======
class Header extends Equatable {
  final String key;
  final String value;

  const Header({required this.key, required this.value});

  // factory Header.fromJson(Map<String, dynamic> json) {
  //   return Header(key: json['key'] ?? '', value: json['value'] ?? '');
  // }

  // Map<String, dynamic> toJson() => {'key': key, 'value': value};

  @override
  List<Object> get props => [key, value];

  Header copyWith({String? key, String? value}) {
    return Header(key: key ?? this.key, value: value ?? this.value);
  }

  Map<String, dynamic> toMap() {
    return {'key': key, 'value': value};
  }

  factory Header.fromMap(Map<String, dynamic> map) {
    return Header(key: map['key'] ?? '', value: map['value'] ?? '');
  }

  String toJson() => json.encode(toMap());

  factory Header.fromJson(String source) => Header.fromMap(json.decode(source));

  @override
  String toString() => 'Header(key: $key, value: $value)';
}

// ======= ResponseKey Class =======
class ApiResponse {
  final dynamic data;

  const ApiResponse({required this.data});

  // factory ApiResponse.fromJson(dynamic json) {
  //   return ApiResponse(data: json);
  // }

  // dynamic toJson() => data;

  @override
  List<Object> get props => [data];

  ApiResponse copyWith({dynamic data}) {
    return ApiResponse(data: data ?? this.data);
  }

  Map<String, dynamic> toMap() {
    return data;
  }

  factory ApiResponse.fromMap(Map<String, dynamic> map) {
    return ApiResponse(data: map['data'] ?? null);
  }

  String toJson() => json.encode(toMap());

  factory ApiResponse.fromJson(String source) {
    final decoded = json.decode(source);
    return ApiResponse(data: decoded);
  }

  @override
  String toString() => 'ApiResponse(data: $data)';
}

// ======= RequestObject Class =======
class RequestObject {
  final Map<String, dynamic> request;

  RequestObject(this.request);

  RequestObject addNestedKey(String keys, dynamic value) {
    final newData = Map<String, dynamic>.from(request);
    frameNestedReqObject(newData, keys, value);
    return RequestObject(newData);
  }

  void frameNestedReqObject(
    Map<String, dynamic> obj,
    String keys,
    dynamic value,
  ) {
    final splittedKeys = keys.split(".");
    Map<String, dynamic> current = obj;
    for (int i = 0; i < splittedKeys.length; i++) {
      final key = splittedKeys[i];
      if (i == splittedKeys.length - 1) {
        current[key] = value;
      } else {
        if (current[key] == null || current[key] is! Map<String, dynamic>) {
          current[key] = <String, dynamic>{};
        }
        current = current[key];
      }
    }
  }

  void clearNestedReqObjectValues() {}

  @override
  List<Object> get props => [request];

  RequestObject copyWith({Map<String, dynamic>? request}) {
    return RequestObject(request ?? this.request);
  }

  Map<String, dynamic> toMap() {
    return request;
  }

  factory RequestObject.fromMap(Map<String, dynamic> map) {
    return RequestObject(Map<String, dynamic>.from(map['request']));
  }

  String toJson() => json.encode(toMap());

  factory RequestObject.fromJson(String source) =>
      RequestObject.fromMap(json.decode(source));

  @override
  String toString() => 'RequestObject(request: $request)';
}
