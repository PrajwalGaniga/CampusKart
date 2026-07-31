class ActivityLog {
  final String id;
  final String userId;
  final String action;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    required this.userId,
    required this.action,
    required this.metadata,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      action: json['action'] as String,
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : {},
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
