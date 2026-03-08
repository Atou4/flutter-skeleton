import 'package:dartz/dartz.dart';
import 'package:flutter_skeleton/core/exceptions/error_failures.dart';
import 'package:flutter_skeleton/features/sample_feature/domain/entities/sample_entity.dart';

abstract class SampleRepository {
  Future<Either<Failure, List<SampleEntity>>> fetchItems();

  Future<Either<Failure, SampleEntity>> fetchItemById(String id);
}
