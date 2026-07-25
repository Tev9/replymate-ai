class PendingSyncOperation {
  final String id;
  final String userId;
  final String collection;
  final String documentId;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  const PendingSyncOperation({
    required this.id,
    required this.userId,
    required this.collection,
    required this.documentId,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  PendingSyncOperation copyWith({
    String? id,
    String? userId,
    String? collection,
    String? documentId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    int? retryCount,
  }) {
    return PendingSyncOperation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      collection: collection ?? this.collection,
      documentId: documentId ?? this.documentId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'collection': collection,
      'documentId': documentId,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  factory PendingSyncOperation.fromJson(
    Map<String, dynamic> json,
  ) {
    return PendingSyncOperation(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      collection: json['collection'] as String,
      documentId: json['documentId'] as String,
      data: Map<String, dynamic>.from(
        json['data'] as Map,
      ),
      createdAt: DateTime.parse(
        json['createdAt'] as String,
      ),
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }
}