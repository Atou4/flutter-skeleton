import 'package:equatable/equatable.dart';

class SampleEntity extends Equatable {
  const SampleEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, title, description, createdAt];
}
