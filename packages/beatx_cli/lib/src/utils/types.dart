import 'package:analyzer/dart/element/element.dart';

extension CheckType on ParameterElement {
  bool get isString => type.isDartCoreString;
}
