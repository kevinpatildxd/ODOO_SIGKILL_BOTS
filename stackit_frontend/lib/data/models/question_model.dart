import 'package:json_annotation/json_annotation.dart';
import 'package:stackit_frontend/data/models/user_model.dart';
import 'package:stackit_frontend/data/models/tag_model.dart';

part 'question_model.g.dart';

@JsonSerializable()
class Question {
  final int id;
  final String title;
  final String description;
  final String slug;
  final int userId;
  final int? acceptedAnswerId;
  final int viewCount;
  final int voteCount;
  final int answerCount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  @JsonKey(name: 'user')
  final User? author;
  
  @JsonKey(name: 'tags')
  final List<Tag>? tags;

  Question({
    required this.id,
    required this.title,
    required this.description,
    required this.slug,
    required this.userId,
    this.acceptedAnswerId,
    this.viewCount = 0,
    this.voteCount = 0,
    this.answerCount = 0,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.tags,
  });

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);
}
