// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Answer _$AnswerFromJson(Map<String, dynamic> json) => Answer(
  id: (json['id'] as num).toInt(),
  content: json['content'] as String,
  questionId: (json['questionId'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  isAccepted: json['isAccepted'] as bool? ?? false,
  votes: (json['votes'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  user: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AnswerToJson(Answer instance) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'questionId': instance.questionId,
  'userId': instance.userId,
  'isAccepted': instance.isAccepted,
  'votes': instance.votes,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'user': instance.user,
};
