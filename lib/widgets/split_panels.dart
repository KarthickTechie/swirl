/*
    @auth     : karthick.d    06/10/2025
    @desc     : parent container for all the three panel
                split_panel - keep the list of BPWidgt which app
                  items_panel
                
*/
import 'dart:convert';
import 'dart:math';

import 'package:dashboard/appdata/page/bpappbar.dart';
import 'package:dashboard/appdata/page/bppage_schema.dart';
import 'package:dashboard/appdata/page/page_global_constants.dart';
import 'package:dashboard/appstyles/global_colors.dart';
import 'package:dashboard/bloc/bpinbox/bpwidget_inbox_props_bloc.dart';
import 'package:dashboard/bloc/bpinbox/model/bpwiddgetinboxprops.dart';
import 'package:dashboard/bloc/bpwidgetaction/model/action/bpwidget_action.dart';
import 'package:dashboard/bloc/bpwidgetaction/model/dataprovider/navigation_task_param.dart';
import 'package:dashboard/bloc/bpwidgetaction/model/jobs/bpwidget_job.dart';
import 'package:dashboard/bloc/bpwidgetaction/model/tasks/navigation_task.dart';
import 'package:dashboard/bloc/bpwidgetprops/bpwidget_props_bloc.dart';
import 'package:dashboard/bloc/bpwidgetprops/model/bpwidget_props.dart';
import 'package:dashboard/bloc/bpwidgets/bpwidget_bloc.dart';
import 'package:dashboard/bloc/bpwidgets/model/bpwidget.dart';
import 'package:dashboard/bloc/bpwidgets/model/bpwidget_schema.dart';
import 'package:dashboard/bloc/bpwidgets/page_container.dart';
import 'package:dashboard/core/api/api_call.dart';
import 'package:dashboard/core/api/api_client.dart';
import 'package:dashboard/pages/canva_nav_rail.dart';
import 'package:dashboard/pages/dynamic_form_builder.dart';
import 'package:dashboard/types/bpwidget_types.dart';
import 'package:dashboard/types/drag_drop_types.dart';
import 'package:dashboard/utils/math_utils.dart';
import 'package:dashboard/widgets/custom_navigation_rail.dart';
import 'package:dashboard/widgets/item_panel.dart';
import 'package:dashboard/widgets/mobile_screen.dart';
import 'package:dashboard/widgets/my_drop_region.dart';
import 'package:dashboard/widgets/right_panel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dashboard/pages/canva_nav_rail.dart';

class SplitPanel extends StatefulWidget {
  final int columns;
  final double itemSpacing;
  final List<BpPagesSchema> pagesData;
  const SplitPanel({
    super.key,
    this.columns = 3,
    this.itemSpacing = 2.0,
    required this.pagesData,
  });

  @override
  State<SplitPanel> createState() => _SplitPanelState();
}

class _SplitPanelState extends State<SplitPanel> {
  /// BPPageController named constructor BPPageController.loadNPages(5)
  ///  to create pages on the fly , the created pages will be loaded in
  ///  the left panel -> pages panel where user can select pages to configure
  /// BPWidgets
  ///
  BPPageController bpController = BPPageController.loadNPages(5);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (int i = 0; i < widget.pagesData.length; i++) {
      final BPPageController expPage = BPPageController.createNewPage(
        widget.pagesData[i].pageName,
        widget.pagesData[i].pageId,
      );
      bpController.pagesRegistry.addEntries(expPage.pagesRegistry.entries);
    }
  }

  ///
  late BpPagesSchema bpPagesSchema;
  late List<BpPagesSchema> allPageData = widget.pagesData;
  List<BPWidget> upper = [];
  final List<BPWidget> lower = [
    BPWidget(
      bpwidgetProps: BpwidgetProps(
        label: '',
        controlName: '',
        controlType: PlaceholderWidgets.Textfield.name,
      ),
      widgetType: PlaceholderWidgets.Textfield,
    ),
    BPWidget(
      bpwidgetProps: BpwidgetProps(
        label: '',
        controlName: '',
        controlType: PlaceholderWidgets.Dropdown.name,
      ),
      widgetType: PlaceholderWidgets.Dropdown,
    ),
    BPWidget(
      bpwidgetProps: BpwidgetProps(
        label: '',
        controlName: '',
        controlType: PlaceholderWidgets.Checkbox.name,
      ),
      widgetType: PlaceholderWidgets.Checkbox,
    ),
    BPWidget(
      bpwidgetProps: BpwidgetProps(
        label: '',
        controlName: '',
        controlType: PlaceholderWidgets.Radio.name,
      ),
      widgetType: PlaceholderWidgets.Radio,
    ),
    BPWidget(
      bpwidgetProps: BpwidgetProps(
        label: '',
        controlName: '',
        controlType: PlaceholderWidgets.Button.name,
      ),
      widgetType: PlaceholderWidgets.Button,
    ),
    BPWidget(
      bpwidgetProps: BpwidgetProps(
        label: '',
        controlName: '',
        controlType: PlaceholderWidgets.Label.name,
      ),
      widgetType: PlaceholderWidgets.Label,
    ),
    BPWidget(
      bpwidgetProps: BPWidgetInboxProps(
        apiName: '',
        title: '',
        subtitle: '',
        key1: '',
        key2: '',
        key3: ''
      ),
      widgetType: PlaceholderWidgets.inbox,
    ),
  ];

  PanelLocation dragStart = (-1, Panel.lower);
  PanelLocation? dropPreview;

  BPWidget? hoveringData;
  BPWidget? selectedWidgetProps;

  int navSelectedIndex = 0;

  // BpPagesSchema pagesSchema = BpPagesSchema(
  //   pageId: '',
  //   pageName: '',
  //   appBar: null,
  //   bpWidgetList:[],
  // );

  /// this method is called when the itemplaceholder is dragged
  /// it's set  the state -> dragStart and data state properties
  ///
  void onItemDragStart(PanelLocation start) {
    final data = switch (start.$2) {
      Panel.upper => upper[start.$1],
      Panel.lower => lower[start.$1],
    };

    setState(() {
      dragStart = start;
      hoveringData = data;
    });
  }

  void updateDropPreview(PanelLocation update) => setState(() {
    dropPreview = update;
  });

  /// this function invoked when the formcontrol widget dragged and dropped to
  /// central panel , unique id is assigned to id property of BPWidgetProps
  ///
  void drop() {
    setState(() {
      if (dropPreview!.$2 == Panel.upper) {
        final uniqueID = MathUtils.generateUniqueID();
        // print('onDrop => ${lower[dropPreview!.$1].bpwidgetProps}');
        // print('hoveringData!.widgetType => ${hoveringData!.widgetType!.name}');
        if (hoveringData!.widgetType!.name == 'inbox') {
          hoveringData = BPWidget(
            widgetType: hoveringData!.widgetType,
            id: uniqueID,
            bpwidgetProps: BPWidgetInboxProps(
              id: uniqueID,
              apiName: '',
              title: '',
              subtitle: '',
              key1: '',
              key2: '',
              key3: ''
            ),
            bpwidgetAction: [
              BpwidgetAction.initWithId(id: uniqueID),
            ], // list of formcontrolactions
          );

          print('hoveringData => ${hoveringData!.id}');
          upper.insert(max(dropPreview!.$1, upper.length), hoveringData!);
          print("final inbox upper list => $upper");
        } else {
          hoveringData = BPWidget(
            widgetType: hoveringData!.widgetType,
            id: uniqueID,
            bpwidgetProps: BpwidgetProps(
              label: '',
              controlName:
                  '${bpController.pagesRegistry.entries.first.value.pageName}_',

              controlType: hoveringData!.widgetType!.name,
              id: uniqueID,
            ),
            bpwidgetAction: [
              BpwidgetAction.initWithId(id: uniqueID),
            ], // list of formcontrolactions
          );

          print('hoveringData => ${hoveringData!.id}');
          upper.insert(max(dropPreview!.$1, upper.length), hoveringData!);
        }
        
      }
    });
  }

  void onItemClickRef(BPWidget widget) {
    print('onItemClickRef => ${widget}');
    selectedWidgetProps = widget;
    setState(() {});
  }

  void _onPageDetailsSaved(BpPagesSchema pageSchema) {
    bpPagesSchema = pageSchema;
    print(jsonEncode(bpPagesSchema));
  }

  void _onPageSelected(BpPagesSchema? pageDataSchema) {
    print("pageDataSchemaOnPAgeSelected----->${pageDataSchema}");
    if (pageDataSchema != null) {
      print("pageDataSchema.bpWidgetLis----->${pageDataSchema.bpWidgetList}");
      setState(() {
        upper = [];
        for (final bpWidget in pageDataSchema.bpWidgetList!.schema) {
          if (bpWidget.widgetType!.name == 'inbox') {
            final bpWidgetInboxProps = bpWidget.bpwidgetProps! as BPWidgetInboxProps;
            final bpWidgetAction = bpWidget.bpwidgetAction!;

            hoveringData = BPWidget(
              widgetType: bpWidget.widgetType,
              id: bpWidget.id,

              bpwidgetProps: BPWidgetInboxProps(
                id: bpWidgetInboxProps.id,
                apiName: bpWidgetInboxProps.apiName,
                title: bpWidgetInboxProps.title, 
                subtitle: bpWidgetInboxProps.subtitle, 
                key1: bpWidgetInboxProps.key1, 
                key2: bpWidgetInboxProps.key2, 
                key3: bpWidgetInboxProps.key3
              ),
              bpwidgetAction: [
                BpwidgetAction.initWithId(id: bpWidgetAction[0].id),
              ], // list of formcontrolactions
            );

            print('hoveringData => ${hoveringData!.id}');
            upper.insert(upper.length, hoveringData!);
          } else {
            final bpWidgetProps = bpWidget.bpwidgetProps! as BpwidgetProps;
            final bpWidgetAction = bpWidget.bpwidgetAction!;

            hoveringData = BPWidget(
              widgetType: bpWidget.widgetType,
              id: bpWidget.id,

              bpwidgetProps: BpwidgetProps(
                label: bpWidgetProps.label,
                controlName: bpWidgetProps.controlName,
                controlType: bpWidgetProps.controlType,
                id: bpWidgetProps.id,
              ),
              bpwidgetAction: [
                BpwidgetAction.initWithId(id: bpWidgetAction[0].id),
              ], // list of formcontrolactions
            );

            print('hoveringData => ${hoveringData!.id}');
            upper.insert(upper.length, hoveringData!);
          }
          
        }
        final appBar = pageDataSchema.appBar!;
        final actionButton = appBar.actionButton[0];
        final action = jsonDecode(actionButton['action']);
        final schema = BpwidgetSchema(schema: upper);

        final taskDataProvider = NavigationTaskDataProvider(
          url: action['job']['taskDataprovider']['url'],
        );

        final tasks = [
          NavigationTask(
            id: MathUtils.generateUniqueID(),
            name: Task.checkUrl.name,
          ),
          NavigationTask(
            id: MathUtils.generateUniqueID(),
            name: Task.navigation.name,
          ),
        ];
        final job = BPwidgetJob(
          type: action['job']['type'],
          id: action['job']['id'],
          name: action['job']['name'],
          taskDataprovider: taskDataProvider,
          tasks: tasks,
        );

        final actionObj = BpwidgetAction(
          name: action['name'],
          id: action['id'],
          job: job,
        );

        final appBarObj = BPAppBarConfig(
          title: pageDataSchema.appBar!.title,
          actionButton: [
            {'name': actionButton['name'], 'action': actionObj},
          ],
        );
        bpPagesSchema = BpPagesSchema(
          pageId: pageDataSchema.pageId,
          pageName: pageDataSchema.pageName,
          appBar: appBarObj,
          bpWidgetList: schema,
        );
      });
    } else {
      setState(() {
        hoveringData = null;
        upper = [];
      });
    }
  }

  callApi(pageSaverequest, url) async {
    try {
      Response response =
          await ApiCall(
            dio: ApiClient().getDio(),
            url: url,
            // url:"http://172.30.3.246:8000/api/getApiSchemaById/",
            method: "POST",
            request: pageSaverequest,
          ).callApi();
      print('response-------------->$response');
      return response;
    } catch (error) {
      print(error);
    }
  }

  getCallApi() async {
    Map<String, dynamic> req = {"id": "54321"};
    try {
      final response =
          await ApiCall(
            dio: ApiClient().getDio(),
            // url: "http://172.30.3.246:8000/api/savePageSchema/", //save pages
            // url: "http://172.30.3.246:8000/api/getPageSchemaById/", //get a page
            url:
                "https://swirl-backend.vercel.app/api/getAllPagesSchema/", //get All pages

            method: "POST",
            request: req,
          ).callApi();
      print('response-------------->$response');
      final data =
          response is String ? jsonDecode(response) : response.data ?? response;
      if (allPageData != null) {
        allPageData = [];
        for (int i = 0; i < data.length; i++) {
          final schemaString = data[i]['schema'];
          final schemaDecoded = jsonDecode(schemaString);
          final pagesData = BpPagesSchema.fromJson(
            schemaDecoded['BpPagesSchema'][0],
          );
          allPageData.add(pagesData);
          print(pagesData.pageName);
          print("pagesData$i----------------->$pagesData");
        }
      }

      // print(pagesData!.pageName);

      print('bpPagesSchema-------------->$allPageData');
      return allPageData;
    } catch (error) {
      print(error);
    }
  }

  framPageRequestSave(BpPagesSchema pageData) {
    return {
      "clientId": "56789",
      "clientName": "CodeTech",
      "appId": "54321",
      "appName": "Agri",
      "pageName": pageData.pageName,
      "pageId": pageData.pageId,
      "pageDesc": "toStore Personal Info of the user",
      "schema": jsonEncode(pageData),
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BpwidgetBloc, BpwidgetState>(
      /// listener method will be invoked when ever the BPWidgetState objet
      /// changes . in our case whenever we are adding the Bpwidgets in
      /// List<BpWidgets>
      listener: (context, state) {
        if (upper[0].widgetType!.name == 'inbox') {
          final bpWidgetStateProps =  state.bpWidgetsList![0].bpwidgetProps! as BPWidgetInboxProps;
          final upperFiltered = upper.where((u) {
            return u.id == bpWidgetStateProps.id;
          });
          final indexOfSelectedBpWidget = upper.indexOf(upperFiltered.first);

          if (indexOfSelectedBpWidget != -1) {
            BPWidget _upper = upperFiltered.first;
            final upperWidget = _upper.bpwidgetProps! as BPWidgetInboxProps;

            _upper.bpwidgetProps =  upperWidget.copyWith(
              id: bpWidgetStateProps.id,
              apiName: bpWidgetStateProps.apiName,
              title: bpWidgetStateProps.title,
              subtitle: bpWidgetStateProps.subtitle,
              key1: bpWidgetStateProps.key1,
              key2: bpWidgetStateProps.key2,
              key3: bpWidgetStateProps.key3,
            );
            if (state.bpWidgetsList![0].bpwidgetAction == null) {
            _upper.bpwidgetAction = [BpwidgetAction.initWithId(id: '')];
            } else {
              _upper.bpwidgetAction = state.bpWidgetsList![0].bpwidgetAction;
            }
            upper[indexOfSelectedBpWidget] = _upper;
          }

          final jsonList = context.read<BpwidgetInboxPropsBloc>().state.jsonListData;
          final inboxList = jsonList!['responseData']['leadlists'] ?? [];
        } else {
          final bpWidgetStateProps =  state.bpWidgetsList![0].bpwidgetProps! as BpwidgetProps;
          final upperFiltered = upper.where((u) {
            return u.id == bpWidgetStateProps.id;
          });
          final indexOfSelectedBpWidget = upper.indexOf(upperFiltered.first);
          if (indexOfSelectedBpWidget != -1) {
            BPWidget _upper = upperFiltered.first;
            final upperWidget = _upper.bpwidgetProps! as BpwidgetProps;

            _upper.bpwidgetProps = upperWidget.copyWith(
              controlName: bpWidgetStateProps.controlName,
              label: bpWidgetStateProps.label,
              controlType: bpWidgetStateProps.controlType,
              isRequired: bpWidgetStateProps.isRequired,
              isVerificationRequired:
                  bpWidgetStateProps.isVerificationRequired,
              max: bpWidgetStateProps.max,
              min: bpWidgetStateProps.min,
              validationPatterns:
                  bpWidgetStateProps.validationPatterns,
              id: bpWidgetStateProps.id,
            );
            if (state.bpWidgetsList![0].bpwidgetAction == null) {
              _upper.bpwidgetAction = [BpwidgetAction.initWithId(id: '')];
            } else {
              _upper.bpwidgetAction = state.bpWidgetsList![0].bpwidgetAction;
            }

            // _upper.copyWith(bpwidgetProps: state.bpWidgetsList![0].bpwidgetProps);
            upper[indexOfSelectedBpWidget] = _upper;
          }
        }
        
      },
      builder: (context, state) {
        print(
          'total pages => ${bpController.pagesRegistry.entries.first.value.pageName}',
        );

        return Scaffold(
          appBar: AppBar(
            // toolbarTextStyle: TextStyle(color: Colors.white,fontWeight:FontWeight.w600),
            iconTheme: GlobalColors.iconThemeWhite,
            titleTextStyle: GlobalColors.titleTextStyleWhite,
            actionsIconTheme: GlobalColors.iconThemeWhite,
            title: Text('BuildPerfect', style: TextStyle(fontSize: 25)),
            flexibleSpace: Container(
              decoration: BoxDecoration(gradient: GlobalColors.appBarBGColor),
            ),
            elevation: 2,
            actions: [
              IconButton(
                onPressed: () async {
                  final schema = BpwidgetSchema(schema: upper);
                  // final schemaJson = schema.toJson();
                  // final schemaWidget = BpwidgetSchema.fromJson(schemaJson);
                  bpPagesSchema = BpPagesSchema(
                    pageId: bpPagesSchema.pageId,
                    pageName: bpPagesSchema.pageName,
                    appBar: bpPagesSchema.appBar,
                    bpWidgetList: schema,
                  );

                  final pageSaverequest = framPageRequestSave(bpPagesSchema);
                  await callApi(
                    pageSaverequest,
                    "https://swirl-backend.vercel.app/api/savePageSchema/",
                  );

                  setState(() async {
                    await getCallApi();
                    print(
                      "widget.pagesData insid save All--------->${widget.pagesData}",
                    );
                  });
                },
                icon: Icon(Icons.save),
              ),
              IconButton(
                onPressed: () {
                  final schema = BpwidgetSchema(schema: upper);
                  final schemaJson = schema.toJson();
                  final schemaWidget = BpwidgetSchema.fromJson(schemaJson);
                  bpPagesSchema = BpPagesSchema(
                    pageId: bpPagesSchema.pageId,
                    pageName: bpPagesSchema.pageName,
                    appBar: bpPagesSchema.appBar,
                    bpWidgetList: schema,
                  );

                  print('schema => $schemaJson');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => MobileScreen(pageData: bpPagesSchema),
                    ),
                  );
                },
                icon: Icon(Icons.code),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final gutter = widget.columns + 1;
              final spaceForColumns =
                  constraints.maxWidth - (widget.itemSpacing * gutter);
              final columnWidth = spaceForColumns / widget.columns;
              final itemSize = Size(columnWidth, columnWidth);
              final double navrailWidth = 100;
              final leftPanelWidth = constraints.maxWidth / 5;
              final centerPanelWidth = constraints.maxWidth / 2;
              final rightPanelWidth =
                  constraints.maxWidth -
                  (leftPanelWidth + centerPanelWidth) +
                  80;
              final leftPanelheight = constraints.maxHeight / 2;
              return Stack(
                children: [
                  Positioned(
                    width: navrailWidth,
                    left: 0,
                    height: constraints.maxHeight,
                    child: CanvaNavigationRailExample(),
                    // child: CustomNavigationRail(
                    //   selectedIconTheme: GlobalColors.navSelectIcomeThem,
                    //   indicatorColor: GlobalColors.navIndicatorColor,
                    //   selectedIndex: navSelectedIndex,
                    //   isExtend: false,
                    //   label: ["Home", "Pages", "More"],
                    //   icons: [Icons.home, Icons.file_copy, Icons.more],
                    //   backgroundColor: GlobalColors.navBGColor,
                    //   onDestinationSelected: (value) {
                    //     setState(() {
                    //       navSelectedIndex = value;
                    //       if (navSelectedIndex == 0) {
                    //         Navigator.pop(context);
                    //       }
                    //     });
                    //   },
                    // ),
                  ),
                  Positioned(
                    // for draggable component
                    width: leftPanelWidth - 10,
                    height: leftPanelheight - 2,
                    left: navrailWidth - 25,
                    top: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Color(0xFFF0F1F5)),
                      child: MyDropRegion(
                        onDrop: drop,
                        updateDropPreview: updateDropPreview,
                        childSize: itemSize,
                        columns: widget.columns,
                        panel: Panel.lower,

                        child: ItemPanel(
                          width: leftPanelWidth - 20,
                          crossAxisCount: widget.columns,
                          spacing: widget.itemSpacing,
                          items: lower,

                          onDragStart: onItemDragStart,
                          panel: Panel.lower,
                          dragStart: dragStart,
                          dropPreview: dropPreview,
                          hoveringData: hoveringData,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    width: leftPanelWidth - 10,
                    height: leftPanelheight - 2,
                    left: navrailWidth - 25,
                    bottom: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Color(0xFFF0F1F5)),
                      child: PageContainer(
                        bpPageSchema: allPageData,
                        width: leftPanelWidth - 100,
                        bpPageController: bpController,
                        onPageDetailsSaved: _onPageDetailsSaved,
                        onPageClicked: _onPageSelected,
                      ),
                    ),
                  ),
                  Positioned(
                    width: 2,
                    height: constraints.maxHeight,
                    left: leftPanelWidth + 70,
                    child: ColoredBox(color: GlobalColors.centerPanelBGColor),
                  ),
                  Positioned(
                    // centerpanel for dragtarget
                    width: centerPanelWidth,
                    height: constraints.maxHeight,
                    left: leftPanelWidth + 70,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: GlobalColors.centerPanelBGColor,
                      ),
                      child: MyDropRegion(
                        onDrop: drop,
                        updateDropPreview: updateDropPreview,
                        childSize: itemSize,
                        columns: widget.columns,
                        panel: Panel.upper,
                        child: ItemPanel(
                          width: leftPanelWidth - 100,
                          crossAxisCount: widget.columns,
                          spacing: widget.itemSpacing,
                          items: upper,

                          onDragStart: onItemDragStart,
                          panel: Panel.upper,
                          dragStart: dragStart,
                          dropPreview: dropPreview,
                          hoveringData: hoveringData,
                          onItemClicked: onItemClickRef,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    width: rightPanelWidth,
                    height: constraints.maxHeight,
                    right: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Color(0xFFF0F1F5)),

                      /// RightPanel - is parent model for props , action and
                      /// datasource panel
                      child: RightPanel(
                        width: rightPanelWidth,
                        height: constraints.maxHeight,
                        props: selectedWidgetProps,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
