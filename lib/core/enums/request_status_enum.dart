enum RequestStatusEnum {
  open,
  inProgress,
  resolved,
  cancelled;

  String get apiValue {
    switch (this) {
      case RequestStatusEnum.open:
        return 'Aberta';
      case RequestStatusEnum.inProgress:
        return 'Em andamento';
      case RequestStatusEnum.resolved:
        return 'Resolvida';
      case RequestStatusEnum.cancelled:
        return 'Cancelada';
    }
  }

  static RequestStatusEnum fromApi(String value) =>
      RequestStatusEnum.values.firstWhere(
        (s) => s.apiValue == value,
        orElse: () => RequestStatusEnum.open,
      );
}
