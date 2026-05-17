import 'package:injectable/injectable.dart';
import '../storage/database.dart';

/// Provides the Drift database singleton to injectable's DI container.
@module
abstract class DatabaseModule {
  @lazySingleton
  SentraDatabase get sentraDatabase;
}

/// Concrete implementation for the DI module.
class DatabaseModuleImpl extends DatabaseModule {
  @override
  SentraDatabase get sentraDatabase => SentraDatabase();
}
