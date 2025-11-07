import 'dart:convert';

import 'package:dashboard/bloc/apiBuilder/apibuilder_props_bloc.dart';
import 'package:dashboard/bloc/apiBuilder/apibuilder_props_event.dart';
import 'package:dashboard/bloc/apiBuilder/apibuilder_props_state.dart';
import 'package:dashboard/bloc/apiBuilder/model/apibuilder_props.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ApiLeftPanel extends StatefulWidget {
  const ApiLeftPanel({super.key});

  @override
  State<ApiLeftPanel> createState() => _ApiLeftPanelState();
}

class _ApiLeftPanelState extends State<ApiLeftPanel> {
  String searchQuery = "";
  var filteredApis = [];

  @override
  void initState() {
    super.initState();
    _loadSavedApis();
  }

  Future<void> _loadSavedApis() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList('saved_apis') ?? [];

    if (savedList.isNotEmpty) {
      final List<ApiModel> loadedApis =
          savedList.map((item) => ApiModel.fromJson(jsonDecode(item))).toList();

      // Push loaded APIs into BLoC
      for (var api in loadedApis) {
        context.read<ApiBloc>().add(AddApi(api));
      }

      debugPrint("✅ Loaded ${loadedApis.length} APIs from local storage");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApiBloc, ApiState>(
      builder: (context, state) {
        final filteredApis =
            state.apis
                .where(
                  (api) =>
                      api.apiName.toLowerCase().contains(searchQuery) ||
                      api.apiEndpoint.toLowerCase().contains(searchQuery),
                )
                .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged:
                    (val) => setState(() => searchQuery = val.toLowerCase()),
                decoration: InputDecoration(
                  hintText: "Search....",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredApis.length,
                itemBuilder: (context, index) {
                  final api = filteredApis[index];
                  final stateApis = context.read<ApiBloc>().state.apis;
                  print('stateApis------------->$stateApis');

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(api.apiName),
                      subtitle: Text(api.apiEndpoint),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editApi(stateApis.indexOf(api)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteApi(stateApis.indexOf(api)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteApi(int index) {
    // context.read<ApiBloc>().add(DeleteApi(index));
  }

  void _editApi(int index) {
    context.read<ApiBloc>().add(SelectedApiIndex(index));
    // final api = context.read<ApiBloc>().state.apis[index];

    // form.reset();
    // form.patchValue({
    //   'apiName': api.apiName,
    //   'apiEndpoint': api.apiEndpoint,
    //   'apiMethodName': api.apiMethodName,
    //   'httpMethod': api.httpMethod,
    // });

    // final headersArray = form.control('headers') as FormArray;
    // final responseArray = form.control('responses') as FormArray;
    // setState(() {
    //   headersArray.clear();
    //   for (var h in api.headers) {
    //     headersArray.add(
    //       FormGroup({
    //         'key': FormControl<String>(value: h.key),
    //         'value': FormControl<String>(value: h.value),
    //       }),
    //     );
    //   }
    //   requestObject = api.requestKeys;
    //   responseObject = api.responses;
    //   print('responseArray----------->${responseArray}');
    // });
  }
}
