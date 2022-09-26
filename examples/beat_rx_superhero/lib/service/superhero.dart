import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'superhero.g.dart';

const idMin = 1;
const idMax = 731;
const tokenEnv = 'SUPERHERO_TOKEN';
const TOKEN = 'YOUR_TOKEN';

@JsonSerializable()
class Superhero {
  const Superhero(this.id, this.name, this.imageUrl);

  final String id;
  final String name;
  @JsonKey(
    name: 'image',
    fromJson: imageUrlFromJson,
  )
  final String imageUrl;

  static Future<Superhero> fromId(int id) async {
    final token = Platform.environment[tokenEnv] ?? TOKEN;
    final response = await http
        .get(Uri.parse('https://www.superheroapi.com/api/$token/$id'));

    final body = response.body;
    return Superhero.fromJson(jsonDecode(body));
  }

  factory Superhero.fromJson(Map<String, dynamic> json) =>
      _$SuperheroFromJson(json);

  static String imageUrlFromJson(Map<String, dynamic> json) =>
      json['url'] ?? '';
}
