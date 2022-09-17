// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteNode _$RouteNodeFromJson(Map<String, dynamic> json) => RouteNode(
      path: json['path'] as String,
      libPath: json['libPath'] as String,
      parent: json['parent'] as String? ?? '',
      isRoot: json['isRoot'] as bool? ?? false,
    );

Map<String, dynamic> _$RouteNodeToJson(RouteNode instance) => <String, dynamic>{
      'libPath': instance.libPath,
      'path': instance.path,
      'parent': instance.parent,
      'isRoot': instance.isRoot,
    };
