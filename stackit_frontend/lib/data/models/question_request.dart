import 'package:json_annotation/json_annotation.dart';

part 'question_request.g.dart';

@JsonSerializable()
class CreateQuestionRequest {
  final String title;
  final String description;
  final List<String> tags;

  CreateQuestionRequest({
    required this.title,
    required this.description,
    required this.tags,
  });

  factory CreateQuestionRequest.fromJson(Map<String, dynamic> json) => _$CreateQuestionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateQuestionRequestToJson(this);
}

@JsonSerializable()
class UpdateQuestionRequest {
  final String title;
  final String description;
  final List<String> tags;

  UpdateQuestionRequest({
    required this.title,
    required this.description,
    required this.tags,
  });

  factory UpdateQuestionRequest.fromJson(Map<String, dynamic> json) => _$UpdateQuestionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateQuestionRequestToJson(this);
}