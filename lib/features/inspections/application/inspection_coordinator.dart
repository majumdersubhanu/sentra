import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../domain/inspection.dart';
import '../domain/inspection_repository.dart';

@lazySingleton
class InspectionCoordinator {
  final InspectionRepository _repository;

  InspectionCoordinator(this._repository);

  Future<Either<Failure, List<Inspection>>> fetchInspections() {
    return _repository.getInspections();
  }

  Future<Either<Failure, Unit>> submitInspection(Inspection inspection) {
    final submitted = inspection.copyWith(status: InspectionStatus.completed);
    return _repository.saveInspection(submitted);
  }
}
