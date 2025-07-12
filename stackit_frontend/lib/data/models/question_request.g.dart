// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateQuestionRequest _$CreateQuestionRequestFromJson(
  Map<String, dynamic> json,
) => CreateQuestionRequest(
  title: json['title'] as String,
  description: json['description'] as String,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$CreateQuestionRequestToJson(
  CreateQuestionRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'tags': instance.tags,
};

UpdateQuestionRequest _$UpdateQuestionRequestFromJson(
  Map<String, dynamic> json,
) => UpdateQuestionRequest(
  title: json['title'] as String,
  description: json['description'] as String,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$UpdateQuestionRequestToJson(
  UpdateQuestionRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'tags': instance.tags,
};
