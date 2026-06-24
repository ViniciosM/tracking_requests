enum RequestPriorityEnum {
  low,
  medium,
  high;

  String get apiValue => name;

  static RequestPriorityEnum fromApi(String value) =>
      RequestPriorityEnum.values.firstWhere(
        (p) => p.apiValue == value,
        orElse: () => RequestPriorityEnum.medium,
      );
}
