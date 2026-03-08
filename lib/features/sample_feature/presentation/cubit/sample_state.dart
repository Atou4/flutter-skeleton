import 'package:equatable/equatable.dart';
import 'package:flutter_skeleton/features/sample_feature/domain/entities/sample_entity.dart';

sealed class SampleState extends Equatable {
  const SampleState();

  @override
  List<Object?> get props => [];
}

final class SampleInitial extends SampleState {}

final class SampleLoading extends SampleState {}

final class SampleLoaded extends SampleState {
  const SampleLoaded({required this.items});

  final List<SampleEntity> items;

  @override
  List<Object?> get props => [items];
}

final class SampleError extends SampleState {
  const SampleError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
