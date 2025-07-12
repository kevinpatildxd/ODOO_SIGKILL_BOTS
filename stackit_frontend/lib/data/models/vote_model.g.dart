// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vote _$VoteFromJson(Map<String, dynamic> json) => Vote(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  targetType: json['targetType'] as String,
  targetId: (json['targetId'] as num).toInt(),
  voteType: (json['voteType'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$VoteToJson(Vote instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'targetType': instance.targetType,
  'targetId': instance.targetId,
  'voteType': instance.voteType,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
