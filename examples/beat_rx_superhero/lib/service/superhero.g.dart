// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'superhero.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Superhero _$SuperheroFromJson(Map<String, dynamic> json) => Superhero(
      json['id'] as String,
      json['name'] as String,
      Superhero.imageUrlFromJson(json['image'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SuperheroToJson(Superhero instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'image': instance.imageUrl,
    };
