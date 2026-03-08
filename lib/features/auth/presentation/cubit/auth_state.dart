part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class UserAuthenticated extends AuthState {
  const UserAuthenticated({this.userId});

  final String? userId;

  @override
  List<Object?> get props => [userId];
}

final class UserUnAuthenticated extends AuthState {}

final class AuthError extends AuthState {
  const AuthError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
