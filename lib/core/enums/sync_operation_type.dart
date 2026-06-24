enum SyncOperationTypeEnum {
  create,
  updateStatus;

  String get dbValue {
    switch (this) {
      case SyncOperationTypeEnum.create:
        return 'create';
      case SyncOperationTypeEnum.updateStatus:
        return 'update_status';
    }
  }

  static SyncOperationTypeEnum fromDb(String value) =>
      SyncOperationTypeEnum.values.firstWhere(
        (o) => o.dbValue == value,
        orElse: () => SyncOperationTypeEnum.create,
      );
}
