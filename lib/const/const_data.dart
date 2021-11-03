import 'package:flutter/cupertino.dart';

import '../models/language_info.dart';

class ConstData {
  static final List<LanguageInfo> supportedLanguages = [
    LanguageInfo(
        countryCode: "US", languageCode: "en", title: "English", flag: "🇺🇸"),
    LanguageInfo(
        countryCode: "SA", languageCode: "ar", title: "Arabic", flag: "🇸🇦"),
  ];

  static const List<String> rtl_language_codes = [
    'ar', // Arabic
    'fa', // Farsi
    'he', // Hebrew
    'ps', // Pashto
    'ur', // Urdu
  ];

  static const List<Color> green_gradient = [
    Color.fromRGBO(54, 213, 152, 1),
    Color.fromRGBO(26, 185, 124, 1),
  ];

  static const Color pending_color = Color.fromRGBO(255, 221, 87, 1);
  static const Color failure_color = Color.fromRGBO(255, 84, 106, 1);
  static const Color success_color = Color.fromRGBO(0, 43, 109, 1);
  static const Color delay_color = Color.fromRGBO(143, 30, 30, 1);
  static const Color green_color = Color.fromRGBO(49, 200, 142, 1);
  static const Color permission_color = Color.fromRGBO(0, 106, 102, 1);
  static const Color report_color = Color.fromRGBO(11, 81, 145, 1);
  static const Color client_visit_color = Color.fromRGBO(249, 143, 103, 1);

  static const Map<int, String> listOfMonths = {
    1: "jan",
    2: "feb",
    3: "mar",
    4: "apr",
    5: "may",
    6: "jun",
    7: "jul",
    8: "aug",
    9: "sep",
    10: "oct",
    11: "nov",
    12: "dec"
  };

  static const Map<int, String> listOfDays = {
    7: "sun",
    1: "mon",
    2: "tue",
    3: "wed",
    4: "thu",
    5: "fri",
    6: "sat",
  };
}
