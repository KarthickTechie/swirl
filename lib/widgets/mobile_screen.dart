/*
  @author   : ganeshkumar.b  15/10/2025
  @desc     : Mobile Screen Widget used to render Application preview 
              in Device Preview for user to get Mobile Expereince
*/

import 'dart:convert';

import 'package:dashboard/appdata/page/bpappbar.dart';
import 'package:dashboard/appdata/page/bppage_schema.dart';
import 'package:dashboard/core/api/api_call.dart';
import 'package:dashboard/core/api/api_client.dart';
import 'package:dashboard/pages/dashboard_page.dart';
import 'package:dashboard/pages/dynamic_form_builder.dart';
import 'package:dashboard/pages/inbox_page_builder.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dashboard/bloc/bpwidgets/model/bpwidget.dart';
import 'package:device_preview/device_preview.dart';

class MobileScreen extends StatefulWidget {
  final BpPagesSchema pageData;
  const MobileScreen({super.key, required this.pageData});

  @override
  State<MobileScreen> createState() => MobileScreenState();
}

class MobileScreenState extends State<MobileScreen> {
  List<BPWidget> pageRenderData = [];
  late final BPAppBarConfig appbarData;
  Map<String, dynamic> pageSaverequest = {};
  Map<String, dynamic> getRequest = {};

  @override
  void initState() {
    super.initState();
    setState(() {
      pageRenderData = widget.pageData.bpWidgetList!.schema;
      appbarData = widget.pageData.appBar!;
      print(widget.pageData.pageId);
      print(widget.pageData.pageName);
      // pageSaverequest = framPageRequestSave(widget.pageData);
      getRequest = frameRequestgetSchemaById("1917610464");
      
    // callApi();
    });
  }

  

  frameRequestgetSchemaById(String PageId){
    return {
      "id":PageId
    };
  }

  @override
  Widget build(BuildContext context) {
    return DevicePreview(
      // enabled: !kReleaseMode,
      builder:
          (context) => MaterialApp(
            useInheritedMediaQuery: true, // Required for DevicePreview
            locale: DevicePreview.locale(context),
            builder: DevicePreview.appBuilder,
            title: 'Device Preview Navigation Demo',
            // home: DynamicForm(widgetSchema: pageRenderData,appBar:widget.pageData),
            // home: DynamicForm(pagesSchema: widget.pageData),
            home: InboxPageBuilder(widgetSchema: pageRenderData),
            routes: {'/second': (context) => const DashboardPage()},
          ),
    );
  }
}
