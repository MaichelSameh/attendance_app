class LanguageInfo {
  late String _countryCode;
  late String _flag;
  late String _languageCode;
  late String _title;

  LanguageInfo({
    required String countryCode,
    required String languageCode,
    required String title,
    required String flag,
  }) {
    this._countryCode = countryCode;
    this._flag = flag;
    this._languageCode = languageCode;
    this._title = title;
  }

  String get countryCode => this._countryCode;
  String get flag => this._flag;
  String get languageCode => this._languageCode;
  String get title => this._title;

  @override
  String toString() {
    return '''
    country_code: $countryCode,
    flag: $flag,
    title: $title,
    language_code: $languageCode
  ''';
  }
}
