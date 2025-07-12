// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateAnswerRequest _$CreateAnswerRequestFromJson(Map<String, dynamic> json) =>
    CreateAnswerRequest(
      content: json['content'] as String,
      questionId: (json['questionId'] as num).toInt(),
    );

Map<String, dynamic> _$CreateAnswerRequestToJson(
  CreateAnswerRequest instance,
) => <String, dynamic>{
  'content': instance.content,
  'questionId': instance.questionId,
};

UpdateAnswerRequest _$UpdateAnswerRequestFromJson(Map<String, dynamic> json) =>
    UpdateAnswerRequest(content: json['content'] as String);

Map<String, dynamic> _$UpdateAnswerRequestToJson(
  UpdateAnswerRequest instance,
) => <String, dynamic>{'content': instance.content};
