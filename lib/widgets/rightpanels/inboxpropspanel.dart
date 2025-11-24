import 'package:dashboard/appdata/forms/bpwidget_forms.dart';
import 'package:dashboard/bloc/bpinbox/bpwidget_inbox_props_bloc.dart';
import 'package:dashboard/bloc/bpinbox/model/bpwiddgetinboxprops.dart';
import 'package:dashboard/bloc/bpwidgets/bpwidget_bloc.dart';
import 'package:dashboard/bloc/bpwidgets/model/bpwidget.dart';
import 'package:dashboard/types/global_types.dart';
import 'package:dashboard/utils/math_utils.dart';
import 'package:dashboard/widgets/customcontrols/key_value_reactive_dropdown.dart';
import 'package:dashboard/widgets/rightpanels/panel_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_forms/reactive_forms.dart';

class InboxPropsPanel extends StatefulWidget {
  final double width;
  final double height;
  final BPWidget? props;
  const InboxPropsPanel({
    super.key,
    required this.width,
    required this.height,
    required this.props,
  });

  @override
  State<InboxPropsPanel> createState() => _InboxPropsPanelState();
}

class _InboxPropsPanelState extends State<InboxPropsPanel> {
  late final FormGroup bpWidgetInboxPropsForm;
  final dropDownTextStyle = TextStyle(fontSize: 12);
  _InboxPropsPanelState() : super();

  List<String> JsonDataKey = [];

  @override
  void initState() {
    bpWidgetInboxPropsForm = BpwidgetForms.get_bpwidgetinboxprops_forms();
  }

  @override
  Widget build(BuildContext context) {
    final BPWidgetInboxProps inboxProps = widget.props!.bpwidgetProps as BPWidgetInboxProps;
    return BlocConsumer<BpwidgetInboxPropsBloc, BpwidgetInboxPropsState>(
      listener: (context, state) {
        if (state.saveStatus == SaveStatus.saved) {
          context.read<BpwidgetBloc>().add(
            BpwidgetLoadProps(
              bpWidget: BPWidget(
                bpwidgetProps: state.bpWidgetInboxProps                
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        List<String>? keyListData = state.keyList!.isNotEmpty ? state.keyList : [];
        if (widget.props != null) {
          final  bpWidgetInboxProps = widget.props!.bpwidgetProps! as BPWidgetInboxProps;

          if (bpWidgetInboxProps.apiName != '') {
            bpWidgetInboxPropsForm.controls['apiName']?.updateValue(
              bpWidgetInboxProps.apiName,
            );
          }
          
          bpWidgetInboxPropsForm.controls['title']?.updateValue(
            bpWidgetInboxProps.title,
          );
          bpWidgetInboxPropsForm.controls['subtitle']?.updateValue(
            bpWidgetInboxProps.subtitle,
          );
          bpWidgetInboxPropsForm.controls['key1']?.updateValue(
            bpWidgetInboxProps.key1,
          );
          bpWidgetInboxPropsForm.controls['key2']?.updateValue(
            bpWidgetInboxProps.key2,
          );
          bpWidgetInboxPropsForm.controls['key3']?.updateValue(
            bpWidgetInboxProps.key3,
          );
        }
        
        return ReactiveForm(
          formGroup: bpWidgetInboxPropsForm,
          child: Card(
            color: Colors.white,
            child: SizedBox(
              width: widget.width,
              height: widget.height,

              child: Column(
                children: [
                  PanelHeader(
                    panelWidth: widget.width,
                    title: 'Configure Formcontrol Properties',
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: KeyValueReactiveDropdown(
                      width: widget.width,
                      labeltext: 'Select Api',
                      dropdownEntries: ['getLead', 'getProposalLead'],
                      onSelected: (value) {
                        context.read<BpwidgetInboxPropsBloc>().add(
                          OnApiSelect(
                            apiName: bpWidgetInboxPropsForm.controls['apiName']!.value.toString()
                          )
                        );
                      },
                      formControlName: 'apiName',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: KeyValueReactiveDropdown(
                      width: widget.width,
                      labeltext: 'title',
                      dropdownEntries: keyListData!,
                      formControlName: 'title',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: KeyValueReactiveDropdown(
                      width: widget.width,
                      labeltext: 'subtitle',
                      dropdownEntries: keyListData,
                      formControlName: 'subtitle',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: KeyValueReactiveDropdown(
                      width: widget.width,
                      labeltext: 'key1',
                      dropdownEntries: keyListData,
                      formControlName: 'key1',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: KeyValueReactiveDropdown(
                      width: widget.width,
                      labeltext: 'key2',
                      dropdownEntries: keyListData,
                      formControlName: 'key2',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: KeyValueReactiveDropdown(
                      width: widget.width,
                      labeltext: 'key3',
                      dropdownEntries: keyListData,
                      formControlName: 'key3',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            print(
                              'bpWidgetInboxPropsForm.value => ${bpWidgetInboxPropsForm.value}',
                            );
                            if (bpWidgetInboxPropsForm.valid) {
                              context.read<BpwidgetInboxPropsBloc>().add(
                                InboxPropsSave(
                                  props: BPWidgetInboxProps.fromMap({
                                    'apiName': bpWidgetInboxPropsForm.controls['apiName']!.value,
                                    'title': bpWidgetInboxPropsForm.controls['title']!.value,
                                    'subtitle': bpWidgetInboxPropsForm.controls['subtitle']!.value,
                                    'id': inboxProps.id,
                                    'key1': bpWidgetInboxPropsForm.controls['key1']!.value,
                                    'key2': bpWidgetInboxPropsForm.controls['key2']!.value,
                                    'key3': bpWidgetInboxPropsForm.controls['key3']!.value,
                                  }),
                                ),
                              );
                            } else {
                              print("not valide");
                            }
                          },
                          label: Text('save'),
                          icon: Icon(Icons.save),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
