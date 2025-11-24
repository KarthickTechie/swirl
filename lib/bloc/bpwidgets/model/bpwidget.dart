import 'dart:convert';

import 'package:dashboard/bloc/bpinbox/model/bpwiddgetinboxprops.dart';
import 'package:dashboard/bloc/bpwidgets/model/bp_props.dart';
import 'package:flutter/foundation.dart';

/*
  @author     :   karthick.d  09/10/2025
  @desc   
*/
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dashboard/bloc/bpwidgetaction/model/action/bpwidget_action.dart';
import 'package:dashboard/bloc/bpwidgetprops/model/bpwidget_props.dart';
import 'package:dashboard/types/drag_drop_types.dart';

class BPWidget {
  final PlaceholderWidgets? widgetType;
  final String? id;
  BpProps? bpwidgetProps;
  List<BpwidgetAction>? bpwidgetAction;
  BPWidget({this.widgetType, this.id, this.bpwidgetProps, this.bpwidgetAction});

  BPWidget copyWith({
    PlaceholderWidgets? widgetType,
    String? id,
    BpwidgetProps? bpwidgetProps,
    List<BpwidgetAction>? bpwidgetAction,
  }) {
    return BPWidget(
      widgetType: widgetType ?? this.widgetType,
      id: id ?? this.id,
      bpwidgetProps: bpwidgetProps ?? this.bpwidgetProps,
      bpwidgetAction: bpwidgetAction ?? this.bpwidgetAction,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'widgetType': widgetType?.name,
      'id': id,
      'bpwidgetProps': bpwidgetProps?.toMap(),
      'bpwidgetAction':
          bpwidgetAction != null
              ? bpwidgetAction!.map((x) => x.toMap()).toList()
              : '',
    };
  }

  factory BPWidget.fromMap(Map<String, dynamic> map) {
    return BPWidget(
      widgetType: PlaceholderWidgets.values.firstWhere(
        (e) => e.name == map['widgetType'],
      ),
      id: map['id'] != null ? map['id'] as String : null,
      bpwidgetProps: map['widgetType'] == 'inbox' ? (
          map['bpwidgetProps'] != null 
              ? BPWidgetInboxProps.fromMap(
                  map['bpwidgetProps'] as Map<String,dynamic>) : null
        ) :
          map['bpwidgetProps'] != null
              ? BpwidgetProps.fromMap(
                map['bpwidgetProps'] as Map<String, dynamic>,
              ) : null,
      bpwidgetAction:
          map['bpwidgetAction'] != null
              ? List<BpwidgetAction>.from(
                (map['bpwidgetAction'] as List<dynamic>).map<dynamic>(
                  (x) => BpwidgetAction.fromMap(x as Map<String, dynamic>),
                ),
              )
              : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory BPWidget.fromJson(String source) =>
      BPWidget.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BPWidget(widgetType: $widgetType, id: $id, bpwidgetProps: $bpwidgetProps, bpwidgetAction: $bpwidgetAction)';
  }

  @override
  bool operator ==(covariant BPWidget other) {
    if (identical(this, other)) return true;

    return other.widgetType == widgetType &&
        other.id == id &&
        other.bpwidgetProps == bpwidgetProps &&
        listEquals(other.bpwidgetAction, bpwidgetAction);
  }

  @override
  int get hashCode {
    return widgetType.hashCode ^
        id.hashCode ^
        bpwidgetProps.hashCode ^
        bpwidgetAction.hashCode;
  }
}
