import 'package:flutter/material.dart';
import 'package:flutter_skeleton/core/services/local_storage/local_storage_service.dart';
import 'package:flutter_skeleton/features/shared/language/presentation/cubit/base_cubit.dart';

class LanguageCubit extends BaseCubit<Locale> {
  LanguageCubit(this.localStorageService) : super(const Locale('en'));

  final LocalStorageService localStorageService;

  void getCurrentLanguage() {
    handleRepositoryCall(
      call: () async {
        final langCode = localStorageService.getString(key: 'lang');
        return Locale(langCode ?? 'en', '');
      },
      onSuccess: emit,
    );
  }

  void changeLanguage(String languageCode) {
    handleRepositoryCall(
      call: () async {
        await localStorageService.setValue(key: 'lang', value: languageCode);
        return Locale(languageCode, '');
      },
      onSuccess: emit,
    );
  }

  @override
  Locale? createErrorState(String message) => const Locale('en');
}
