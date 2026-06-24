enum RequestCategoryEnum {
  appointment,
  exam,
  medication,
  billing,
  general;

  String get apiValue => name;

  static RequestCategoryEnum fromApi(String value) =>
      RequestCategoryEnum.values.firstWhere(
        (c) => c.apiValue == value,
        orElse: () => RequestCategoryEnum.general,
      );
}
