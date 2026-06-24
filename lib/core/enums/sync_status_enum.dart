enum SyncStatusEnum {
  synced,
  pending,
  failed;

  String get dbValue => name;

  static SyncStatusEnum fromDb(String value) =>
      SyncStatusEnum.values.firstWhere(
        (s) => s.dbValue == value,
        orElse: () => SyncStatusEnum.synced,
      );
}
