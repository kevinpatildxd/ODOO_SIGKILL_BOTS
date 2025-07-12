import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class Notification {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final String? referenceType;
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.referenceType,
    this.referenceId,
    this.isRead = false,
    required this.createdAt,
  });

  // Create a copy with updated fields
  Notification copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? message,
    String? referenceType,
    String? referenceId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Notification.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);
  
  Map<String, dynamic> toJson() => _$NotificationToJson(this);
  
  // Convert to a JSON string
  String toRawJson() => json.encode(toJson());
  
  // Create an instance from a JSON string
  factory Notification.fromRawJson(String str) => 
      Notification.fromJson(json.decode(str) as Map<String, dynamic>);
}
