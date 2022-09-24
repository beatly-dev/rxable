// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteInfo _$RouteInfoFromJson(Map<String, dynamic> json) => RouteInfo(
      libPath: json['libPath'] as String,
      routePath: json['routePath'] as String,
      widgetName: json['widgetName'] as String,
      parentRoutePath: json['parentRoutePath'] as String? ?? '',
      isRoot: json['isRoot'] as bool? ?? false,
      isLayout: json['isLayout'] as bool? ?? false,
    );

Map<String, dynamic> _$RouteInfoToJson(RouteInfo instance) => <String, dynamic>{
      'libPath': instance.libPath,
      'routePath': instance.routePath,
      'parentRoutePath': instance.parentRoutePath,
      'widgetName': instance.widgetName,
      'isRoot': instance.isRoot,
      'isLayout': instance.isLayout,
    };
