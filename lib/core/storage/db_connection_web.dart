// ignore_for_file: deprecated_member_use

import 'package:drift/drift.dart';
import 'package:drift/web.dart';
import 'package:flutter/foundation.dart';

Future<QueryExecutor> openDriftConnection() async {
  return WebDatabase('sentra_web_db', logStatements: kDebugMode);
}
