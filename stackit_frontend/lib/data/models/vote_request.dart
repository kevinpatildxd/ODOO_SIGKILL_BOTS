import 'package:json_annotation/json_annotation.dart';

part 'vote_request.g.dart';

@JsonSerializable()
class VoteRequest {
  final String targetType;
  final int targetId;
  final int voteType;

  VoteRequest({
    required this.targetType,
    required this.targetId,
    required this.voteType,
  });

  factory VoteRequest.fromJson(Map<String, dynamic> json) => _$VoteRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VoteRequestToJson(this);
} 