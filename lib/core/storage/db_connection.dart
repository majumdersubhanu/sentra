import 'package:drift/drift.dart';

import 'db_connection_native.dart'
    if (dart.library.html) 'db_connection_web.dart'
    as impl;

Future<QueryExecutor> openDriftConnection() => impl.openDriftConnection();
