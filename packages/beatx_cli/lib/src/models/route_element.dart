import 'package:json_annotation/json_annotation.dart';
import 'package:source_gen/source_gen.dart';

import 'route_node.dart';

part 'route_element.g.dart';

/// A facade for the [RouteInfo] class
@JsonSerializable()
class RouteElement {
  RouteElement({
    required this.info,
    this.element,
  });
  final RouteInfo info;

  /// This is only required when the generator creates a new page
  @JsonKey(ignore: true)
  final AnnotatedElement? element;

  bool get isRoot => element?.annotation.peek('isRoot')?.boolValue ?? false;

  bool get isLayout => element?.annotation.peek('isLayout')?.boolValue ?? false;

  Map<String, dynamic> toJson() => _$RouteElementToJson(this);
  factory RouteElement.fromJson(Map<String, dynamic> json) =>
      _$RouteElementFromJson(json);

  @override
  String toString() => '''
  RouteElement(
    path: ${info.toJson()},
    element: $element,
  )
  ''';
}
