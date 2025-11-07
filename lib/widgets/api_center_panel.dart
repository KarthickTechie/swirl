import 'dart:convert';

import 'package:dashboard/bloc/apiBuilder/apibuilder_props_bloc.dart';
import 'package:dashboard/bloc/apiBuilder/apibuilder_props_event.dart';
import 'package:dashboard/bloc/apiBuilder/apibuilder_props_state.dart';
import 'package:dashboard/bloc/apiBuilder/model/apibuilder_props.dart';
import 'package:dashboard/core/api/api_call.dart';
import 'package:dashboard/core/api/api_client.dart';
import 'package:dashboard/utils/math_utils.dart';
import 'package:dashboard/widgets/customcontrols/key_value_reactive_dropdown.dart';
import 'package:dashboard/widgets/customcontrols/key_value_reactive_textbox.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ApiCenterPanel extends StatefulWidget {
  const ApiCenterPanel({super.key});

  @override
  State<ApiCenterPanel> createState() => _ApiCenterPanelState();
}

class _ApiCenterPanelState extends State<ApiCenterPanel> {
  final form = FormGroup({
    'apiName': FormControl<String>(validators: [Validators.required]),
    'apiEndpoint': FormControl<String>(validators: [Validators.required]),
    'apiMethodName': FormControl<String>(),
    'httpMethod': FormControl<String>(validators: [Validators.required]),
    'headers': FormArray([]),
    'requestKey': FormArray([]),
    'responses': FormArray([]),
  });

  final headerEntryForm = FormGroup({
    'key': FormControl<String>(validators: [Validators.required]),
    'value': FormControl<String>(validators: [Validators.required]),
    'otherKey': FormControl<String>(),
    'otherValue': FormControl<String>(),
  });

  final requestEntryForm = FormGroup({
    'key': FormControl<String>(validators: [Validators.required]),
    'value': FormControl<String>(),
  });

  String selectedHeaderKey = '';
  RequestObject requestObject = RequestObject({});
  bool _isLoading = false;
  dynamic responseObject = '';

  List<dynamic> getOptions() {
    switch (selectedHeaderKey.toLowerCase()) {
      case 'authorization':
        return ['Bearer Token', 'Basic Auth'];
      case 'content-type':
        return ['application/json', 'multipart/form-data', 'text/plain'];
      case 'accept':
        return ['application/json', 'text/html'];
      default:
        return [];
    }
  }

  void _saveApi() async {
    try {
      if (form.valid) {
        final headersArray = form.control('headers') as FormArray;
        final api = ApiModel(
          apiName: form.control('apiName').value,
          apiEndpoint: form.control('apiEndpoint').value,
          apiMethodName: form.control('apiMethodName').value ?? '',
          httpMethod: form.control('httpMethod').value,
          headers:
              headersArray.controls
                  .map(
                    (c) => Header(
                      key: c.value['key'] ?? '',
                      value: c.value['value'] ?? '',
                    ),
                  )
                  .toList(),
          requestKeys: requestObject,
          responses: responseObject,
        );

        context.read<ApiBloc>().add(AddApi(api));
        print("api toJson-------------->${api.toJson()}");
        // print('context----->${context.read<ApiBloc>().state.apis}');
        final ApiRequest = {
          "clientId": "1",
          "clientName": "Sysarc",
          "appId": "2",
          "appName": "Email validation",
          "apiName": "sandhiya test",
          "apiId": MathUtils.generateUniqueID(),
          "apiStatus": true,
          "schema": jsonEncode(api.toJson()),
        };
        // Response response;
        print("api-------------->${jsonEncode(api.toJson())}");
        print("request-------------->${ApiRequest}");
        final response =
            await ApiCall(
              dio: ApiClient().getDio(),
              url: 'https://swirl-backend.vercel.app/api/saveApiSchema/',
              method: "POST",
              request: ApiRequest,
            ).callApi();
        print('calling karthick machine-------->$response');
        if (response != null) {
          final prefs = await SharedPreferences.getInstance();
          final currentList = prefs.getStringList('saved_apis') ?? [];
          currentList.add(jsonEncode(api.toJson()));
          await prefs.setStringList('saved_apis', currentList);

          form.reset();
          (form.control('headers') as FormArray).clear();
          (form.control('requestKey') as FormArray).clear();
          (form.control('responses') as FormArray).clear();
          headerEntryForm.reset();
          requestEntryForm.reset();
          responseObject = '';
          requestObject = RequestObject({});
        } else {}
        form.markAllAsTouched();
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> _testApi() async {
    if (!form.valid) {
      form.markAllAsTouched();
      return;
    }
    setState(() => _isLoading = true);
    final url = form.control('apiEndpoint').value;
    final method = form.control('httpMethod').value;
    final headersArray = form.control('headers') as FormArray;


    Map<String, String> headers = {
      for (var h in headersArray.controls)
        if ((h as FormGroup).control('key').value != null &&
            (h).control('value').value != null)
          h.control('key').value: h.control('value').value,
    };

    
    dynamic body =requestObject.toMap();

    try {
      // http.Response response;
      Response response;
      response =
          await ApiCall(
            dio: ApiClient().getDio(),
            url: url,
            method: method,
            headers: headers,
            request: body,
          ).callApi();
      print('response.data--------->${response.data}');
      setState(() {
        // responseObject = ApiResponse.fromJson(jsonEncode(response.data));
        responseObject = response.data;
      });
      print('responseObject------------------>${responseObject}');
      context.read<ApiBloc>().add(AddResponseObject(responseObject));
    } catch (error) {
      print(error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showImportDialog() {
    TextEditingController importController = TextEditingController();
 
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Import API Schema"),
          content: TextField(
            controller: importController,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: "Paste your API definition here...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _parseAndPopulate(importController.text);
                Navigator.pop(context);
              },
              child: const Text("Import"),
            ),
          ],
        );
      },
    );
  }

  void _parseAndPopulate(String rawText) {
  try {
    final endpointMatch = RegExp(r'endpoint\s*:\s*([^\s]+)', caseSensitive: false)
        .firstMatch(rawText);
    final methodMatch = RegExp(r'methodname\s*:\s*(\w+)', caseSensitive: false)
        .firstMatch(rawText);
    final requestMatch = RegExp(
      r'request\s*:\s*(\{[\s\S]*?\})(;|$)',
      caseSensitive: false,
    ).firstMatch(rawText);
    final responseMatch = RegExp(
      r'response\s*:\s*(\{[\s\S]*?\})(;|$)',
      caseSensitive: false,
    ).firstMatch(rawText);
    final endpoint = endpointMatch?.group(1)?.trim() ?? '';
    final method = methodMatch?.group(1)?.trim().toUpperCase() ?? 'GET';
 
    dynamic requestJson = {};
    dynamic responseJson = {};
 
    String safeNormalize(String input) {
      String content = input.trim();
 
      content = content.replaceAll(RegExp(r';+$'), '');
 
      if (!content.startsWith('{')) content = '{$content';
      if (!content.endsWith('}')) content = '$content}';
      content = content.replaceAll("'", '"');
 
      final RegExp pairPattern = RegExp(r'([A-Za-z_][A-Za-z0-9_]*)\s*:\s*([^,}]+)');
      final matches = pairPattern.allMatches(content);
 
      Map<String, dynamic> map = {};
      for (final m in matches) {
        var key = m.group(1)!.trim();
        var value = m.group(2)!.trim();
        value = value.replaceAll(RegExp(r'^"|"$'), '');
 
        dynamic parsedValue;
        if (value == 'true' || value == 'false') {
          parsedValue = value == 'true';
        } else if (value == 'null') {
          parsedValue = null;
        } else if (double.tryParse(value) != null) {
          parsedValue = double.parse(value);
        } else {
          parsedValue = value;
        }
        map[key] = parsedValue;
      }
      return jsonEncode(map);
    }
 
    if (requestMatch != null) {
      final req = safeNormalize(requestMatch.group(1)!);
      requestJson = json.decode(req);
    }
 
    if (responseMatch != null) {
      final res = safeNormalize(responseMatch.group(1)!);
      responseJson = json.decode(res);
    }
 
    form.patchValue({
      'apiEndpoint': endpoint,
      'httpMethod': method,
    });
 
    setState(() {
      requestObject = RequestObject(requestJson);
      responseObject = responseJson;
    });
 
    context.read<ApiBloc>().add(AddRequestObject(requestObject));
    context.read<ApiBloc>().add(AddResponseObject(ApiResponse.fromJson(responseObject)));
 
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API imported successfully!')),
    );
  } catch (e, stack) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Import failed: ${e.toString()}')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApiBloc, ApiState>(
      listener: (context, state) {
        final index = state.selectedApiIndex;
        if (index != null && index < state.apis.length) {
          final api = state.apis[index];
          print('aaaaaaaaaaaa----->$api');
          form.reset();
          form.patchValue({
            'apiName': api.apiName,
            'apiEndpoint': api.apiEndpoint,
            'apiMethodName': api.apiMethodName,
            'httpMethod': api.httpMethod,
          });
        }
      },

      child: SingleChildScrollView(
        child: ReactiveForm(
          formGroup: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildApiInputs(),
              _buildHeaderSection(),
              _buildRequestKeySection(),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testApi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      icon:
                          _isLoading
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              ),
                      label: Text(
                        _isLoading ? "Testing..." : "Test API",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),

                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveApi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        "SAVE",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _showImportDialog,
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      icon: const Icon(Icons.file_upload, color: Colors.white),
                      label: const Text(
                        "IMPORT",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Headers", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ReactiveForm(
            formGroup: headerEntryForm,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KeyValueReactiveDropdown(
                      formControlName: 'key',
                      labeltext: 'Header Key',
                      width: 300,
                      dropdownEntries: const [
                        'authorization',
                        'content-Type',
                        'accept',
                        'other',
                      ],
                      onSelected: (selected) {
                        setState(() {
                          selectedHeaderKey = selected.value;
                        });
                      },
                    ),
                    const SizedBox(width: 20),
                    KeyValueReactiveDropdown(
                      formControlName: 'value',
                      labeltext: 'Header Value',
                      width: 300,
                      dropdownEntries: getOptions(),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: () {
                        if (headerEntryForm.valid) {
                          final headersArray =
                              form.control('headers') as FormArray;
                          headersArray.add(
                            FormGroup({
                              'key': FormControl<String>(
                                value: headerEntryForm.control('key').value,
                              ),
                              'value': FormControl<String>(
                                value: headerEntryForm.control('value').value,
                              ),
                              'otherKey': FormControl<String>(
                                value:
                                    headerEntryForm.control('otherKey').value,
                              ),
                              'otherValue': FormControl<String>(
                                value:
                                    headerEntryForm.control('otherValue').value,
                              ),
                            }),
                          );
                          headerEntryForm.reset();
                          setState(() {
                            selectedHeaderKey = '';
                          });
                        } else {
                          headerEntryForm.markAllAsTouched();
                        }
                      },
                      icon: const Icon(Icons.add),
                      tooltip: "Add",
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                selectedHeaderKey == "other"
                    ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        KeyValueReactiveTextbox(
                          formControlName: 'otherKey',
                          labeltext: 'Header Key',
                          width: 300,
                        ),
                        const SizedBox(width: 20),
                        KeyValueReactiveTextbox(
                          formControlName: 'otherValue',
                          labeltext: 'Header Value',
                          width: 300,
                        ),
                        const SizedBox(width: 20),
                      ],
                    )
                    : SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiInputs() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: KeyValueReactiveTextbox(
            labeltext: 'API name',
            width: 500,
            formControlName: 'apiName',
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: KeyValueReactiveTextbox(
            labeltext: 'API Endpoint(URL)',
            width: 500,
            formControlName: 'apiEndpoint',
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: KeyValueReactiveTextbox(
            labeltext: 'API method name',
            width: 500,
            formControlName: 'apiMethodName',
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: KeyValueReactiveDropdown(
            width: 500,
            labeltext: 'HTTP method',
            dropdownEntries: ['POST', 'GET', 'PUT', 'DELETE'],
            formControlName: 'httpMethod',
          ),
        ),
      ],
    );
  }

  Widget _buildRequestKeySection() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Request Keys", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: 8),
          ReactiveForm(
            formGroup: requestEntryForm,
            child: Row(
              children: [
                KeyValueReactiveTextbox(
                  formControlName: 'key',
                  labeltext: 'Request Key',
                  width: 300,
                ),
                const SizedBox(width: 20),
                KeyValueReactiveTextbox(
                  formControlName: 'value',
                  labeltext: 'Request Value',
                  width: 300,
                ),
                const SizedBox(width: 20),
                IconButton(
                  onPressed: () {
                    if (requestEntryForm.valid) {
                      final key = requestEntryForm.control('key').value;
                      final value = requestEntryForm.control('value').value;

                      setState(() {
                        requestObject = requestObject.addNestedKey(key, value);
                        print(
                          const JsonEncoder.withIndent(
                            '  ',
                          ).convert(requestObject),
                        );
                      });
                      context.read<ApiBloc>().add(
                        AddRequestObject(requestObject),
                      );

                      requestEntryForm.reset();
                    } else {
                      requestEntryForm.markAllAsTouched();
                    }
                  },
                  icon: const Icon(Icons.add),
                  tooltip: "Add",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
