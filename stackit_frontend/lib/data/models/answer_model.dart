import 'package:json_annotation/json_annotation.dart';
import 'package:stackit_frontend/data/models/user_model.dart';

part 'answer_model.g.dart';

@JsonSerializable()
class Answer {
  final int id;
  final String content;
  final int questionId;
  final int userId;
  final bool isAccepted;
  final int voteCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  @JsonKey(name: 'user')
  final User? author;

  Answer({
    required this.id,
    required this.content,
    required this.questionId,
    required this.userId,
    this.isAccepted = false,
    this.voteCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.author,
  });

  factory Answer.fromJson(Map<String, dynamic> json) => _$AnswerFromJson(json);
  Map<String, dynamic> toJson() => _$AnswerToJson(this);
}
