import 'package:dashboard/bloc/apiBuilder/model/apibuilder_props.dart';
import 'package:equatable/equatable.dart';

class ApiState extends Equatable {
  final List<ApiModel> apis;
  final int? selectedApiIndex;
  final RequestObject? requestObject;
  final dynamic apiResponse;

  const ApiState({
    this.apis = const [],
    this.selectedApiIndex,
    this.requestObject,
    this.apiResponse,
  });

  ApiState copyWith({
    List<ApiModel>? apis,
    int? selectedApiIndex,
    RequestObject? requestObject,
    dynamic apiResponse,
  }) {
    return ApiState(
      apis: apis ?? this.apis,
      selectedApiIndex: selectedApiIndex ?? this.selectedApiIndex,
      requestObject: requestObject ?? this.requestObject,
      apiResponse: apiResponse ?? this.apiResponse,
    );
  }

  @override
  List<Object?> get props => [
    apis,
    selectedApiIndex,
    requestObject,
    apiResponse,
  ];
}
