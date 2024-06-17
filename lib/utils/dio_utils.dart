import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

final dio = Dio();

Map<String, dynamic> _parseAndDecode(String response) {
  return jsonDecode(response) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> parseJson(String text) {
  return compute(_parseAndDecode, text);
}