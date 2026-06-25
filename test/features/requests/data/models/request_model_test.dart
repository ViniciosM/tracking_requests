import 'package:flutter_test/flutter_test.dart';
import 'package:tracking_requests/core/enums/request_category_enum.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';
import 'package:tracking_requests/core/enums/sync_status_enum.dart';
import 'package:tracking_requests/features/requests/data/models/request_model.dart';
import 'package:tracking_requests/features/requests/domain/entities/request_entity.dart';

import '../../../../_fixtures.dart';

void main() {
  test('is a subtype of the Request entity', () {
    // Assert
    expect(buildModel(), isA<RequestEntity>());
  });

  test('parses an API object, coercing id to a String remoteId', () {
    // Act
    final model = RequestModel.fromJson(requestJson(id: '42'));

    // Assert
    expect(model.remoteId, '42');
    expect(model.localId, ''); // assigned later, on cache
    expect(model.category, RequestCategoryEnum.appointment);
    expect(model.status, RequestStatusEnum.open);
    expect(model.syncStatus, SyncStatusEnum.synced);
  });

  test('toCreateJson omits local-only fields and uses API enum values', () {
    // Act
    final json = buildModel().toCreateJson();

    // Assert
    expect(json.containsKey('id'), isFalse);
    expect(json.containsKey('localId'), isFalse);
    expect(json.containsKey('syncStatus'), isFalse);
    expect(json['status'], 'Aberta');
    expect(json['category'], 'appointment');
  });
}
