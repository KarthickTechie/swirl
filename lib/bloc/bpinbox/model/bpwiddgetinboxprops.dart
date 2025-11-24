// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:dashboard/bloc/bpwidgets/model/bp_props.dart';

class BPWidgetInboxProps extends BpProps {
  final String? id;
  final String? apiName;
  final String title;
  final String subtitle;
  final String key1;
  final String key2;
  final String key3;
  BPWidgetInboxProps({
    this.id,
    this.apiName,
    required this.title,
    required this.subtitle,
    required this.key1,
    required this.key2,
    required this.key3,

  });

  BPWidgetInboxProps copyWith({
    String? id,
    String? apiName,
    String? title,
    String? subtitle,
    String? key1,
    String? key2,
    String? key3,
  }) {
    return BPWidgetInboxProps(
      id: id ?? this.id,
      apiName: apiName ?? this.apiName,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      key1: key1 ?? this.key1,
      key2: key2 ?? this.key2,
      key3: key3 ?? this.key3,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'apiName': apiName,
      'title': title,
      'subtitle': subtitle,
      'key1': key1,
      'key2': key2,
      'key3': key3,
    };
  }

  factory BPWidgetInboxProps.fromMap(Map<String, dynamic> map) {
    return BPWidgetInboxProps(
      id: map['id'] != null ? map['id'] as String : null,
      apiName: map['apiName'] != null ? map['apiName'] as String : null,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      key1: map['key1'] as String,
      key2: map['key2'] as String,
      key3: map['key3'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory BPWidgetInboxProps.fromJson(String source) => BPWidgetInboxProps.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BPWidgetInboxProps(id: $id, apiName: $apiName, title: $title, subtitle: $subtitle, key1: $key1, key2: $key2, key3: $key3)';
  }

  @override
  bool operator ==(covariant BPWidgetInboxProps other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.apiName == apiName &&
      other.title == title &&
      other.subtitle == subtitle &&
      other.key1 == key1 &&
      other.key2 == key2 &&
      other.key3 == key3;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      apiName.hashCode ^
      title.hashCode ^
      subtitle.hashCode ^
      key1.hashCode ^
      key2.hashCode ^
      key3.hashCode;
  }
}
