// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VoteRequest _$VoteRequestFromJson(Map<String, dynamic> json) => VoteRequest(
  targetType: json['targetType'] as String,
  targetId: (json['targetId'] as num).toInt(),
  voteType: (json['voteType'] as num).toInt(),
);

Map<String, dynamic> _$VoteRequestToJson(VoteRequest instance) =>
    <String, dynamic>{
      'targetType': instance.targetType,
      'targetId': instance.targetId,
      'voteType': instance.voteType,
    };
