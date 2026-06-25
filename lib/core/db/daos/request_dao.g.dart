// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_dao.dart';

// ignore_for_file: type=lint
mixin _$RequestDaoMixin on DatabaseAccessor<AppDatabase> {
  $RequestsTable get requests => attachedDatabase.requests;
  RequestDaoManager get managers => RequestDaoManager(this);
}

class RequestDaoManager {
  final _$RequestDaoMixin _db;
  RequestDaoManager(this._db);
  $$RequestsTableTableManager get requests =>
      $$RequestsTableTableManager(_db.attachedDatabase, _db.requests);
}
