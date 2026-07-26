class PendingSyncOperation {
  final String id;
  final String userId;
  final String collection;
  final String documentId;
  final String? subcollection;
  final String? subdocumentId;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;
  final DateTime? nextRetryAt;

  PendingSyncOperation({
    required this.id,
    required this.userId,
    required this.collection,
    required this.documentId,
    this.subcollection,
    this.subdocumentId,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
    this.nextRetryAt,
  });

  PendingSyncOperation copyWith({
    String? id,
    String? userId,
    String? collection,
    String? documentId,
    String? subcollection,
    String? subdocumentId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    int? retryCount,
    DateTime? nextRetryAt,
    bool clearNextRetryAt = false,
  }) {
    return PendingSyncOperation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      collection: collection ?? this.collection,
      documentId: documentId ?? this.documentId,
      subcollection: subcollection ?? this.subcollection,
      subdocumentId: subdocumentId ?? this.subdocumentId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAt: clearNextRetryAt ? null : nextRetryAt ?? this.nextRetryAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'collection': collection,
      'documentId': documentId,
      'subcollection': subcollection,
      'subdocumentId': subdocumentId,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'nextRetryAt': nextRetryAt?.toIso8601String(),
    };
  }

  factory PendingSyncOperation.fromJson(
    Map<String, dynamic> json,
  ) {
    final nextRetryAtValue = json['nextRetryAt'] as String?;

    return PendingSyncOperation(
      id: json['id'] as String,
      userId: json['userId'] as String,
      collection: json['collection'] as String,
      documentId: json['documentId'] as String,
      subcollection: json['subcollection'] as String?,
      subdocumentId: json['subdocumentId'] as String?,
      data: Map<String, dynamic>.from(
        json['data'] as Map,
      ),
      createdAt: DateTime.parse(
        json['createdAt'] as String,
      ),
      retryCount: json['retryCount'] as int? ?? 0,
      nextRetryAt:
          nextRetryAtValue == null ? null : DateTime.parse(nextRetryAtValue),
    );
  }
}
