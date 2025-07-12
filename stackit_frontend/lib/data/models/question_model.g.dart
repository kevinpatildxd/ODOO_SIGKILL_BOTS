// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  slug: json['slug'] as String,
  userId: (json['userId'] as num).toInt(),
  acceptedAnswerId: (json['acceptedAnswerId'] as num?)?.toInt(),
  viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
  voteCount: (json['voteCount'] as num?)?.toInt() ?? 0,
  answerCount: (json['answerCount'] as num?)?.toInt() ?? 0,
  status: json['status'] as String? ?? 'active',
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  author: json['user'] == null
      ? null
      : User.fromJson(json['user'] as Map<String, dynamic>),
  tags: (json['tags'] as List<dynamic>?)
      ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'slug': instance.slug,
  'userId': instance.userId,
  'acceptedAnswerId': instance.acceptedAnswerId,
  'viewCount': instance.viewCount,
  'voteCount': instance.voteCount,
  'answerCount': instance.answerCount,
  'status': instance.status,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'user': instance.author,
  'tags': instance.tags,
};
