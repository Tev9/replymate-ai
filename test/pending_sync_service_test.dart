import 'package:shared_preferences/shared_preferences.dart';
import 'package:replymate_ai/services/pending_sync_service.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:replymate_ai/models/pending_sync_operation.dart';

void main() {
  test('Pending sync operation survives JSON conversion', () {
    final createdAt = DateTime.utc(2026, 11, 13, 10, 30);

    final original = PendingSyncOperation(
      id: 'test_operation_1',
      userId: 'test_user',
      collection: 'contact_profiles',
      documentId: 'john',
      data: {
        'writingStyle': 'friendly',
        'messageCount': 5,
      },
      createdAt: createdAt,
      retryCount: 2,
      nextRetryAt: createdAt.add(
        const Duration(minutes: 5),
      ),
    );

    final json = original.toJson();

    final restored = PendingSyncOperation.fromJson(json);

    expect(restored.id, original.id);
    expect(restored.userId, original.userId);
    expect(restored.collection, original.collection);
    expect(restored.documentId, original.documentId);
    expect(restored.data, original.data);
    expect(restored.createdAt, original.createdAt);
    expect(restored.retryCount, original.retryCount);
    expect(restored.nextRetryAt, original.nextRetryAt);
  });

  test('Corrupted pending queue throws an error', () async {
    SharedPreferences.setMockInitialValues({
      'pending_sync_operations': 'invalid_json_data',
    });

    final service = PendingSyncService();

    await expectLater(
      service.loadOperations(),
      throwsA(isA<StateError>()),
    );
  });
}
