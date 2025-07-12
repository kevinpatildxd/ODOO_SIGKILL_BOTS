// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  email: json['email'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  bio: json['bio'] as String?,
  reputation: (json['reputation'] as num?)?.toInt() ?? 0,
  role: json['role'] as String? ?? 'user',
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'avatarUrl': instance.avatarUrl,
  'bio': instance.bio,
  'reputation': instance.reputation,
  'role': instance.role,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
