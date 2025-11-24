// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'bpwidget_inbox_props_bloc.dart';

class BpwidgetInboxPropsState extends Equatable {
  final BPWidgetInboxProps bpWidgetInboxProps;
  final Map<String,dynamic>? jsonListData;
  final List<String>? keyList;
  final SaveStatus? saveStatus;

  const BpwidgetInboxPropsState({required this.bpWidgetInboxProps, this.keyList, this.jsonListData, this.saveStatus});

  @override
  List<Object> get props => [bpWidgetInboxProps];

  @override
  bool get stringify => true;

  BpwidgetInboxPropsState copyWith({
    BPWidgetInboxProps? bpWidgetInboxProps,
    Map<String,dynamic>? jsonListData,
    List<String>? keyList,
    SaveStatus? saveStatus,
  }) {
    return BpwidgetInboxPropsState(
      bpWidgetInboxProps: bpWidgetInboxProps ?? this.bpWidgetInboxProps,
      jsonListData: jsonListData ?? this.jsonListData,
      keyList: keyList ?? this.keyList,
      saveStatus: saveStatus ?? this.saveStatus,
    );
  }

  factory BpwidgetInboxPropsState.init() => BpwidgetInboxPropsState(
    bpWidgetInboxProps: BPWidgetInboxProps(
      apiName: '',
      title: '',
      subtitle: '',
      key1: '',
      key2: '',
      key3: ''
    ),
    jsonListData:{},
    keyList: [],
    saveStatus: SaveStatus.init,
  );
}
