import 'package:json_annotation/json_annotation.dart';

part 'answer_request.g.dart';

@JsonSerializable()
class CreateAnswerRequest {
  final String content;
  final int questionId;

  CreateAnswerRequest({
    required this.content,
    required this.questionId,
  });

  factory CreateAnswerRequest.fromJson(Map<String, dynamic> json) => _$CreateAnswerRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateAnswerRequestToJson(this);
}

@JsonSerializable()
class UpdateAnswerRequest {
  final String content;

  UpdateAnswerRequest({
    required this.content,
  });

  factory UpdateAnswerRequest.fromJson(Map<String, dynamic> json) => _$UpdateAnswerRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateAnswerRequestToJson(this);
} 