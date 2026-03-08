import 'package:dartz/dartz.dart';
import 'package:flutter_skeleton/core/exceptions/error_failures.dart';
import 'package:flutter_skeleton/core/network/repository_helper.dart';
import 'package:flutter_skeleton/core/services/crashlytics/crashlytics_service.dart';
import 'package:flutter_skeleton/features/sample_feature/data/datasource/remote/sample_remote_data_source.dart';
import 'package:flutter_skeleton/features/sample_feature/domain/entities/sample_entity.dart';
import 'package:flutter_skeleton/features/sample_feature/domain/repositories/sample_repository.dart';

class SampleRepositoryImpl implements SampleRepository {
  SampleRepositoryImpl({
    required this.remoteDataSource,
    required this.crashlyticsService,
  });

  final SampleRemoteDataSource remoteDataSource;
  final CrashlyticsService crashlyticsService;

  @override
  Future<Either<Failure, List<SampleEntity>>> fetchItems() {
    return RepositoryHelper.executeRequest(
      request: () async {
        final responses = await remoteDataSource.fetchItems();
        return responses.map((r) => r.toEntity()).toList();
      },
      crashlyticsService: crashlyticsService,
      context: 'SampleRepository.fetchItems',
    );
  }

  @override
  Future<Either<Failure, SampleEntity>> fetchItemById(String id) {
    return RepositoryHelper.executeRequest(
      request: () async {
        final response = await remoteDataSource.fetchItemById(id);
        return response.toEntity();
      },
      crashlyticsService: crashlyticsService,
      context: 'SampleRepository.fetchItemById',
    );
  }
}
