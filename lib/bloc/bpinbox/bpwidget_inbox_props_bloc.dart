import 'package:dashboard/appdata/inboxjson.dart';
import 'package:dashboard/bloc/bpinbox/model/bpwiddgetinboxprops.dart';
import 'package:dashboard/types/global_types.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'bpwidget_inbox_props_event.dart';
part 'bpwidget_inbox_props_state.dart';

class BpwidgetInboxPropsBloc extends Bloc<BpwidgetInboxPropsEvent, BpwidgetInboxPropsState>{
  BpwidgetInboxPropsBloc() : super(BpwidgetInboxPropsState.init()) {
    on<InboxPropsInit>(onInboxPropsInit);
    on<InboxPropsSave>(onInboxPropsSave);
    on<OnApiSelect>(onApiResponseChange);
  }

  Future<void> onInboxPropsInit(InboxPropsInit ev, Emitter emit) async {
    print('calling onBPwidgetPropsInit');
    emit(BpwidgetInboxPropsState.init());
  }

  Future<void> onInboxPropsSave(InboxPropsSave ev, Emitter emit) async {
    print('calling onBPwidgetPropsSave => ${ev.props}');
    emit(state.copyWith(bpWidgetInboxProps: ev.props, saveStatus: SaveStatus.saved));
  }

  Future<void> onApiResponseChange(OnApiSelect ev, Emitter emit) async {
    final Map<String, dynamic> getInboxListData = Inboxjson.leadDetailsData;
    final List<Map<String, dynamic>>? inboxList = getInboxListData['responseData']['leadlists'] ?? [];
    // print("inboxList-bpjsonListget $inboxList");
    List<String>? keyListData = (inboxList != null && inboxList.isNotEmpty) ? inboxList[0].keys.toList() : [];
    print("inboxList-keyListData $keyListData");
    emit(state.copyWith(
      saveStatus: SaveStatus.update, 
      jsonListData: getInboxListData,
      keyList: List<String>.from(keyListData)
    ));
  }
} 