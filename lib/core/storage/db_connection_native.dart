import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Opens the connection to the local SQLite database using Drift.
/// Relies on `sqlite3_flutter_libs` for native platform bindings.
Future<QueryExecutor> openDriftConnection() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'sentra_local.sqlite'));

  if (kDebugMode) {
    debugPrint('[Drift] Opening database at: ${file.path}');
  }

  return NativeDatabase(file, logStatements: kDebugMode);
}
