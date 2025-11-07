import 'package:dashboard/bloc/apiBuilder/apibuilder_props_bloc.dart';
import 'package:dashboard/bloc/apiBuilder/apibuilder_props_state.dart';
import 'package:dashboard/widgets/api_center_panel.dart';
import 'package:dashboard/widgets/api_left_panel.dart';
import 'package:dashboard/widgets/api_right_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
 
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(create: (_) => ApiBloc(), child: const SplitPanel()),
    );
  }
}
 
class SplitPanel extends StatefulWidget {
  final int columns;
  final double itemSpacing;
  const SplitPanel({super.key, this.columns = 2, this.itemSpacing = 2.0});
 
  @override
  State<SplitPanel> createState() => _SplitPanelState();
}
 
class _SplitPanelState extends State<SplitPanel> {
  String searchQuery = '';
 
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApiBloc, ApiState>(
      builder: (context, state) {
        final filteredApis = state.apis
            .where((api) =>
                api.apiName.toLowerCase().contains(searchQuery) ||
                api.apiEndpoint.toLowerCase().contains(searchQuery))
            .toList();
 
        return Scaffold(
          appBar: AppBar(title: const Text('API Builder'), elevation: 2),
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final totalWidth = constraints.maxWidth;
              final leftWidth = totalWidth * 0.27;//left
              final centerWidth = totalWidth * 0.46;//center
              final rightWidth = totalWidth * 0.27;//right
 
              return Padding(
                padding: const EdgeInsets.only(top: 8, left: 4, right: 8),
                child: Stack(
                  children: [
                    // LEFT PANEL
                    Positioned(
                      width: leftWidth,
                      height: constraints.maxHeight,
                      left: 0,
                      child: ApiLeftPanel(),
                    ),
 
                    // CENTER PANEL
                    Positioned(
                      width: centerWidth,
                      height: constraints.maxHeight,
                      left: leftWidth,
                      child: ApiCenterPanel(),
                    ),
 
                    // RIGHT PANEL
                    Positioned(
                      width: rightWidth,
                      height: constraints.maxHeight,
                      left: leftWidth + centerWidth,
                      child: ApiRightPanel(),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}