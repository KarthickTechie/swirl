import 'dart:convert';

import 'package:dashboard/appdata/page/bppage_schema.dart';
import 'package:dashboard/core/api/api_call.dart';
import 'package:dashboard/core/api/api_client.dart';
import 'package:dashboard/pages/dashboard_page.dart';
import 'package:dashboard/pages/dynamic_form_builder.dart';
import 'package:dashboard/pages/inbox_page_builder.dart';
import 'package:flutter/material.dart';

class Mobilebuild extends StatefulWidget {
  const Mobilebuild({super.key});

  @override
  State<Mobilebuild> createState() => _MobilebuildState();
}

class _MobilebuildState extends State<Mobilebuild> {
  List<BpPagesSchema> listOfPageSchema = [];
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    callApi();    
  }

  Future<void> callApi() async {
    Map<String, dynamic> req = {"id": "54321"};
    List<BpPagesSchema> bpPagesSchema=[];
    try {
      setState(() {
        isLoading = true;
      });

      final response =
          await ApiCall(
            dio: ApiClient().getDio(),
            // url: "http://172.30.3.246:8000/api/savePageSchema/", //save pages
            // url: "http://172.30.3.246:8000/api/getPageSchemaById/", //get a page
            url: "https://swirl-backend.vercel.app/api/getAllPagesSchema/", //get All pages

            method: "POST",
            request: req,
          ).callApi();
      print('response-------------->$response');

      final data = response is String ? jsonDecode(response) : response.data ?? response;
        for(int i=0;i<data.length;i++){
          final schemaString = data[i]['schema'];
          final schemaDecoded = jsonDecode(schemaString);
          final pagesData = BpPagesSchema.fromJson(
            schemaDecoded['BpPagesSchema'][0],
          );
          bpPagesSchema.add(pagesData);
          print(pagesData.pageName);
          print("pagesData$i----------------->$pagesData");
        }

        print('bpPagesSchema-------------->$bpPagesSchema');
      
      setState(() {
        listOfPageSchema.addAll(bpPagesSchema);
        print("listOfPageSchema => $listOfPageSchema");
        isLoading = false;
      });

    } catch (error) {
      print(error);
      setState(() {
        isLoading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (listOfPageSchema.isEmpty) {
      return const Center(child: Text("No data available"));
    }

    final inboxlist = listOfPageSchema.firstWhere((val) => val.pageId == '2782662943');

    return MaterialApp(
            home: InboxPageBuilder(widgetSchema: inboxlist.bpWidgetList!.schema),
            routes: {'/second': (context) => const DashboardPage()},
          );
  }
}