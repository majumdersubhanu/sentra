import 'dart:ffi';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/open.dart';

bool _isSqliteOverridden = false;

Future<QueryExecutor> openDriftConnection() async {
  if (Platform.isAndroid && !_isSqliteOverridden) {
    _isSqliteOverridden = true;
    open.overrideFor(OperatingSystem.android, () {
      try {
        return DynamicLibrary.open('libsqlite3.so');
      } catch (_) {
        // Fallback for some environments
        return DynamicLibrary.open('sqlite3');
      }
    });
  }

  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'sentra_local.sqlite'));
  if (kDebugMode) {
    debugPrint('[Drift] Opening database at: ${file.path}');
  }
  
  // Use NativeDatabase instead of createInBackground to ensure it runs on the 
  // main isolate where the library is already successfully loaded (as seen in devtools).
  return NativeDatabase(file, logStatements: kDebugMode);
}
