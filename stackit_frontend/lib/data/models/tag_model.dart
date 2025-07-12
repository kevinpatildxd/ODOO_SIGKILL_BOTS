import 'package:json_annotation/json_annotation.dart';

part 'tag_model.g.dart';

@JsonSerializable()
class Tag {
  final int id;
  final String name;
  final String? description;
  final String color;
  final int usageCount;
  final DateTime createdAt;

  Tag({
    required this.id,
    required this.name,
    this.description,
    this.color = '#2196F3',
    this.usageCount = 0,
    required this.createdAt,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
  Map<String, dynamic> toJson() => _$TagToJson(this);
}
