import 'package:dashboard/appdata/page/action_icons.dart';
import 'package:dashboard/appdata/page/bpappbar.dart';
import 'package:dashboard/appdata/page/bppage_schema.dart';
import 'package:dashboard/bloc/bpwidgetaction/model/action/bpwidget_action.dart';
import 'package:dashboard/bloc/bpwidgetaction/model/dataprovider/bpwidget_tasks_dataprovider.dart';
import 'package:dashboard/bloc/bpwidgetaction/model/jobs/bpwidget_job.dart';
import 'package:dashboard/bloc/bpwidgetprops/model/bpwidget_props.dart';
import 'package:dashboard/bloc/bpwidgets/model/bpwidget.dart';
import 'package:dashboard/bloc/bpwidgets/model/bpwidget_schema.dart';
import 'package:dashboard/pages/dashboard_page.dart';
import 'package:dashboard/pages/inbox_page_builder.dart';
import 'package:dashboard/types/drag_drop_types.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'dart:convert';

class DynamicForm extends StatelessWidget {
  // final List<BPWidget> widgetSchema;
  // final BpPagesSchema appBar;
  final BpPagesSchema pagesSchema;

  const DynamicForm({
    Key? key,
    // required this.widgetSchema,
    // required this.appBar,
    required this.pagesSchema,
  }) : super(key: key);

  FormGroup buildFormGroup(List<BPWidget> widgets) {
    final controls = <String, AbstractControl<dynamic>>{};
    for (var widget in widgets) {
      if (widget.widgetType == PlaceholderWidgets.Textfield) {
        final bpWidgetprops = widget.bpwidgetProps! as BpwidgetProps;
        controls[bpWidgetprops.controlName] = FormControl<String>(
          validators: [
            if (bpWidgetprops.isRequired == 'true') Validators.required,
            if (bpWidgetprops.max != null)
              Validators.maxLength(int.parse(bpWidgetprops.max!)),
          ],
        );
      } else if (widget.widgetType == PlaceholderWidgets.Dropdown) {
        final bpWidgetprops = widget.bpwidgetProps! as BpwidgetProps;
        controls[bpWidgetprops.controlName] = FormControl<String>(
          validators: [
            if (bpWidgetprops.isRequired == 'true') Validators.required,
          ],
        );
      }
    }

    return FormGroup(controls);
  }

  List<Widget> buildFormWidgets(List<BPWidget> widgets) {
    return widgets.map((widget) {
      if (widget.widgetType == PlaceholderWidgets.Textfield) {
        final BpwidgetProps bpWidgetprops = widget.bpwidgetProps! as BpwidgetProps;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ReactiveTextField(
            formControlName: bpWidgetprops.controlName,
            decoration: InputDecoration(
              labelText: bpWidgetprops.label,
              border: const OutlineInputBorder(),
            ),
            validationMessages: {
              ValidationMessage.required:
                  (_) => '${bpWidgetprops.label} is required',
              ValidationMessage.maxLength:
                  (_) => 'Maximum length is ${bpWidgetprops.max}',
            },
          ),
        );
      } else if (widget.widgetType == PlaceholderWidgets.Dropdown) {
        final BpwidgetProps bpWidgetprops = widget.bpwidgetProps! as BpwidgetProps;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ReactiveDropdownField<String>(
            formControlName: bpWidgetprops.controlName,
            decoration: InputDecoration(
              labelText: bpWidgetprops.label,
              border: const OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            validationMessages: {
              ValidationMessage.required:
                  (_) => '${bpWidgetprops.label} is required',
            },
          ),
        );
      } else if (widget.widgetType == PlaceholderWidgets.Button) {
        final BpwidgetProps bpWidgetprops = widget.bpwidgetProps! as BpwidgetProps;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ReactiveFormConsumer(
            builder: (context, form, child) {
              return ElevatedButton(
                onPressed:
                    form.valid
                        ? () {
                          final action = widget.bpwidgetAction?.firstWhere(
                            (action) => action.name == 'onclick',
                            orElse:
                                () => BpwidgetAction(
                                  id: '',
                                  name: '',
                                  job: BPwidgetJob(
                                    type: '',
                                    id: '',
                                    name: '',
                                    taskDataprovider: BPTaskDataprovider(
                                      url: '',
                                    ),
                                    tasks: [],
                                  ),
                                ),
                          );
                          if (action != null &&
                              action.job!.type == 'Navigation') {
                            // Placeholder for navigation logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Navigating to ${action.job!.taskDataprovider.url}',
                                ),
                              ),
                            );
                            if (action.job!.taskDataprovider.url
                                    .toLowerCase() ==
                                'dashboard') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DashboardPage(),
                                ),
                              );
                            }
                          }
                        }
                        : null,
                child: Text(bpWidgetprops.label),
              );
            },
          ),
        );
      } else if (widget.widgetType == PlaceholderWidgets.inbox) {
        return InboxPageBuilder(
          widgetSchema: widgets
        );
      }
      return const SizedBox.shrink();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // final schema = BpwidgetSchema.fromJson(jsonSchema);
    final widgets =pagesSchema.bpWidgetList!.schema;
    final formGroup = buildFormGroup(widgets);
    final actionButtons = pagesSchema.appBar!.actionButton.elementAt(0);
    // final action = actionButtons['action'] as BpwidgetAction;
    BpwidgetAction action = BpwidgetAction.fromJson(actionButtons['action']);
    print(actionButtons['name'].toString());
    

    return Scaffold(
      appBar: AppBar(
        title: Text(pagesSchema.appBar!.title),

        actions: [
          if (ActionIcons.getActionIcons().containsKey(actionButtons['name']))
            IconButton(
              onPressed: () {  
                if (action.name != null && action.job!.type == 'Navigation') {
                  // Placeholder for navigation logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Navigating to ${action.job!.taskDataprovider.url}',
                      ),
                    ),
                  );
                  if (action.job!.taskDataprovider.url.toLowerCase() ==
                      'dashboard') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DashboardPage()),
                    );
                  }
                }else{
                   BpwidgetAction(
                                id: '',
                                name: '',
                                job: BPwidgetJob(
                                  type: '',
                                  id: '',
                                  name: '',
                                  taskDataprovider: BPTaskDataprovider(
                                    url: '',
                                  ),
                                  tasks: [],
                                ),
                  );
                }
              },
              icon: ActionIcons.getActionIcons()[actionButtons['name']]!,
            ),
        ],
      ),

      body: ReactiveForm(
        formGroup: formGroup,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              width: 300,
              height: 800,
              // decoration: BoxDecoration(
              //   border: Border.all(
              //     color: Colors.black,
              //     width: 5,
              //     style: BorderStyle.solid,
              //   ),
              //   borderRadius: BorderRadius.circular(10),
              // ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...buildFormWidgets(widgets),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
