import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton/features/sample_feature/domain/repositories/sample_repository.dart';
import 'package:flutter_skeleton/features/sample_feature/presentation/cubit/sample_state.dart';

class SampleCubit extends Cubit<SampleState> {
  SampleCubit({required this.repository}) : super(SampleInitial());

  final SampleRepository repository;

  Future<void> loadItems() async {
    emit(SampleLoading());
    final result = await repository.fetchItems();
    result.fold(
      (failure) => emit(SampleError(message: failure.message)),
      (items) => emit(SampleLoaded(items: items)),
    );
  }
}
