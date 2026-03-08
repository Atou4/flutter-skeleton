import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_skeleton/features/sample_feature/domain/entities/sample_entity.dart';

part 'sample_response.g.dart';

@JsonSerializable()
class SampleResponse {
  const SampleResponse({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory SampleResponse.fromJson(Map<String, dynamic> json) =>
      _$SampleResponseFromJson(json);

  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => _$SampleResponseToJson(this);

  SampleEntity toEntity() => SampleEntity(
        id: id,
        title: title,
        description: description,
        createdAt: createdAt,
      );
}
