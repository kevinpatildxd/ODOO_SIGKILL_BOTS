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
  final int votes;  // Changed from voteCount to votes to match what's used in the provider
  final DateTime createdAt;
  final DateTime updatedAt;
  
  @JsonKey(name: 'user')
  final User? user;  // Changed from author to user to match the fromJson mapping

  Answer({
    required this.id,
    required this.content,
    required this.questionId,
    required this.userId,
    this.isAccepted = false,
    this.votes = 0,  // Changed from voteCount to votes
    required this.createdAt,
    required this.updatedAt,
    this.user,  // Changed from author to user
  });

  // Create a copy with updated fields
  Answer copyWith({
    int? id,
    String? content,
    int? questionId,
    int? userId,
    bool? isAccepted,
    int? votes,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
  }) {
    return Answer(
      id: id ?? this.id,
      content: content ?? this.content,
      questionId: questionId ?? this.questionId,
      userId: userId ?? this.userId,
      isAccepted: isAccepted ?? this.isAccepted,
      votes: votes ?? this.votes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }

  factory Answer.fromJson(Map<String, dynamic> json) => _$AnswerFromJson(json);
  Map<String, dynamic> toJson() => _$AnswerToJson(this);
}
