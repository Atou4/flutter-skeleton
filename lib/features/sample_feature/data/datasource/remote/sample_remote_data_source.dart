import 'package:dio/dio.dart';
import 'package:flutter_skeleton/features/sample_feature/data/models/sample_response.dart';
import 'package:retrofit/retrofit.dart';

part 'sample_remote_data_source.g.dart';

@RestApi()
abstract class SampleRemoteDataSource {
  factory SampleRemoteDataSource(Dio dio, {String baseUrl}) =
      _SampleRemoteDataSource;

  @GET('/samples')
  Future<List<SampleResponse>> fetchItems();

  @GET('/samples/{id}')
  Future<SampleResponse> fetchItemById(@Path('id') String id);
}
