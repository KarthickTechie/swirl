import 'dart:convert';

import 'package:dashboard/bloc/apiBuilder/apibuilder_props_bloc.dart';
import 'package:dashboard/bloc/apiBuilder/apibuilder_props_state.dart';
import 'package:dashboard/bloc/apiBuilder/model/apibuilder_props.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ApiRightPanel extends StatefulWidget {
  const ApiRightPanel({super.key});

  @override
  State<ApiRightPanel> createState() => _ApiRightPanelState();
}

class _ApiRightPanelState extends State<ApiRightPanel> {
  Map<String, dynamic> headersObject = {};
  // RequestObject requestObject = RequestObject({});
  // ApiResponse responseObject = ApiResponse(data: "");
  //  final headersArray = form.control('headers') as FormArray;
  //   Map<String, String> headersObject = {};
  //   for (var h in headersArray.controls) {
  //     final group = h as FormGroup;
  //     final key = group.control('key').value;
  //     final value = group.control('value').value;
  //     final otherKey = group.control('otherKey').value;
  //     final otherValue = group.control('otherValue').value;

  //     if (key != null && value != null && key.toString().isNotEmpty) {
  //       headersObject[key] = value;
  //     }
  //     if (otherKey != null &&
  //         otherValue != null &&
  //         otherKey.toString().isNotEmpty) {
  //       headersObject[otherKey] = otherValue;
  //     }
  //   }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApiBloc, ApiState>(
      //   buildWhen: (previous, current) =>
      // previous.requestObject != current.requestObject,
      builder: (context, state) {
         final index = state.selectedApiIndex;
         final api = (index != null && index < state.apis.length)
            ? state.apis[index]
            : null;
        // if (index != null && index < state.apis.length) {
        //   final api = state.apis[index];
        //   requestObject = api.requestKeys;
        //   responseObject = api.responses;
        // }
        print('Right panel ------->${state}');
        RequestObject requestObject = state.requestObject ?? api?.requestKeys ?? RequestObject({});
        dynamic responseObject = state.apiResponse ?? api?.responses ?? {};
        print('requestObject--------->$requestObject');
      return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Structured View",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Headers Object:",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 6, bottom: 12),
              padding: const EdgeInsets.all(8),
              color: Colors.white,
              child: Text(
                _formatAsJson(headersObject),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            Text(
              "Request Object:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.white,
              child: Text(
                // _formatAsJson(requestObject),
                JsonEncoder.withIndent('  ').convert(requestObject.toMap()),
                // requestObject.toJson(),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            Text(
              "Response Object:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                maxHeight: 250,
              ), // 👈 Fixed height scroll box
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              child: SingleChildScrollView(
                // 👈 Scrollable container
                scrollDirection: Axis.vertical,
                child: SelectableText(
                  // responseObject,
                  JsonEncoder.withIndent('  ').convert(responseObject),
                  // _formatAsJson(responseObject),
                  // buildResponseJson(responseArray),
                  // responseObject,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  },
    );
  }

  String _formatAsJson(Map<dynamic, dynamic> obj) {
    return obj.isEmpty
        ? "{}"
        : "{\n${obj.entries.map((e) => '  \"${e.key}\": \"${e.value}\"').join(',\n')}\n}";
  }
}
