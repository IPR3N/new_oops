import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:new_oppsfarm/pages/auth/services/auth_service.dart';

class AuthState {
  final int? userId;

  AuthState({this.userId});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    final token = await _authService.readToken();
    if (token != null) {
      final decoded = JwtDecoder.decode(token);
      state = AuthState(userId: decoded['id']);
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthService());
});
