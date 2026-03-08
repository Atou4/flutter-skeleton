import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_skeleton/features/sample_feature/presentation/cubit/sample_cubit.dart';
import 'package:flutter_skeleton/features/sample_feature/presentation/cubit/sample_state.dart';

class SampleScreen extends StatelessWidget {
  const SampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sample Feature')),
      body: BlocBuilder<SampleCubit, SampleState>(
        builder: (context, state) {
          return switch (state) {
            SampleInitial() => const Center(
                child: Text('Press the button to load items'),
              ),
            SampleLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
            SampleLoaded(:final items) => ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item.title),
                    subtitle: Text(item.description),
                  );
                },
              ),
            SampleError(:final message) => Center(
                child: Text('Error: $message'),
              ),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<SampleCubit>().loadItems(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
