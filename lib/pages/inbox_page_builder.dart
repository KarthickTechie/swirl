import 'package:dashboard/appdata/inboxjson.dart';
import 'package:dashboard/bloc/bpinbox/model/bpwiddgetinboxprops.dart';
import 'package:dashboard/bloc/bpwidgetaction/model/action/bpwidget_action.dart';
import 'package:dashboard/bloc/bpwidgetaction/model/dataprovider/bpwidget_tasks_dataprovider.dart';
import 'package:dashboard/bloc/bpwidgetaction/model/jobs/bpwidget_job.dart';
import 'package:dashboard/bloc/bpwidgets/model/bpwidget.dart';
import 'package:dashboard/pages/dashboard_page.dart';
import 'package:dashboard/widgets/lead_tile_card.dart';
import 'package:flutter/material.dart';

class InboxPageBuilder extends StatelessWidget{
  final List<BPWidget> widgetSchema;
  const InboxPageBuilder({super.key, required this.widgetSchema});

  getListInbox(apiName) {
    try {
      final Map<String, dynamic> getInboxListData = Inboxjson.leadDetailsData;
      final List<Map<String, dynamic>>? inboxList = getInboxListData['responseData']['leadlists'] ?? [];
      return inboxList;
    } catch (error) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {

    final pbWidgetProps = widgetSchema[0].bpwidgetProps as BPWidgetInboxProps;
    final List<Map<String, dynamic>>? inboxList = getListInbox(pbWidgetProps.apiName);
    print("inboxList $inboxList");
    
    return Scaffold(
      appBar: AppBar(title: Text('Lead Inbox Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: inboxList!.length,
          itemBuilder: (context, index) {
            final lead = inboxList[index];
            return SingleChildScrollView(
              child: SafeArea(
                child: LeadTileCard(
                  title: lead['${pbWidgetProps.title}'],
                  subtitle: lead['${pbWidgetProps.subtitle}'],
                  icon: Icons.person,
                  color: Colors.teal,
                  phone: lead['${pbWidgetProps.key1}'],
                  createdon: lead['${pbWidgetProps.key2}'],
                  location: lead['${pbWidgetProps.key3}'],
                  loanamount: '25850',
                  onTap: () {
                    final action = widgetSchema[0].bpwidgetAction?.firstWhere(
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
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}