// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_tree.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteTree _$RouteTreeFromJson(Map<String, dynamic> json) => RouteTree(
      (json['nodes'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, RouteNode.fromJson(e as Map<String, dynamic>)),
      ),
    )..constructed = json['constructed'] as bool;

Map<String, dynamic> _$RouteTreeToJson(RouteTree instance) => <String, dynamic>{
      'nodes': instance.nodes,
      'constructed': instance.constructed,
    };

RouteNode _$RouteNodeFromJson(Map<String, dynamic> json) => RouteNode(
      info: RouteInfo.fromJson(json['info'] as Map<String, dynamic>),
      tree: RouteTree.fromJson(json['tree'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RouteNodeToJson(RouteNode instance) => <String, dynamic>{
      'info': instance.info,
      'tree': instance.tree,
    };
