import 'package:flutter/widgets.dart';
import 'package:reactive_forms/reactive_forms.dart';

class BpwidgetForms {
  static FormGroup get_bpwidgetprops_forms() => FormGroup({
    'label': FormControl<String>(),
    'controlName': FormControl<String>(),
    'controlType': FormControl<String>(),
    'isRequired': FormControl<String>(),
    'min': FormControl<String>(),
    'max': FormControl<String>(),
    'isVerificationRequired': FormControl<String>(),
    'validationPatterns': FormControl<String>(),
  });

  /// reactive formgroup object for actions form in actionspanel
  static FormGroup get_bpwidgetaction_forms() => FormGroup({
    'event': FormControl<String>(),
    'action': FormControl<String>(),
    'pageurl': FormControl<String>(),
  });

  static FormGroup get_bpwidgetinboxprops_forms() => FormGroup({
    'apiName': FormControl<String>(),
    'title': FormControl<String>(),
    'subtitle': FormControl<String>(),
    'key1': FormControl<String>(),
    'key2': FormControl<String>(),
    'key3': FormControl<String>(),
  });

  static FormGroup get_pageConfiguration_form(){
    return  FormGroup({
      'title':FormControl<String>(),
      'actionButton':FormControl<String>(),
      'action':FormControl<String>(),
      'pageUrl':FormControl<String>(),
    });
  }
}
