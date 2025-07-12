import 'package:json_annotation/json_annotation.dart';

part 'vote_model.g.dart';

@JsonSerializable()
class Vote {
  final int id;
  final int userId;
  final String targetType;
  final int targetId;
  final int voteType;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vote({
    required this.id,
    required this.userId,
    required this.targetType,
    required this.targetId,
    required this.voteType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vote.fromJson(Map<String, dynamic> json) => _$VoteFromJson(json);
  Map<String, dynamic> toJson() => _$VoteToJson(this);
}
