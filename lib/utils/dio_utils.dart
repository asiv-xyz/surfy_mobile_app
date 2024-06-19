import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

final dioObject = Dio();

dynamic _parseAndDecode(String response) {
  return jsonDecode(response);
}

Future<dynamic> parseJson(String text) {
  return compute(_parseAndDecode, text);
}