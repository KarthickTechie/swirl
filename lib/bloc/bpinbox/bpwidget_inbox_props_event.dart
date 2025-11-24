part of 'bpwidget_inbox_props_bloc.dart';

abstract class BpwidgetInboxPropsEvent {}

class InboxPropsInit extends BpwidgetInboxPropsEvent {
  final BPWidgetInboxProps props;
  InboxPropsInit({required this.props});
}

class InboxPropsSave extends BpwidgetInboxPropsEvent {
  final BPWidgetInboxProps props;
  InboxPropsSave({required this.props});
}

class OnApiSelect extends BpwidgetInboxPropsEvent {
  final String apiName;
  OnApiSelect({required this.apiName});
}