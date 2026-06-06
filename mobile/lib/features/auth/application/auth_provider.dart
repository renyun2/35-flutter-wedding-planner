import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/wedding_repository.dart';

class AuthState {
  const AuthState({
    required this.token,
    required this.user,
    this.wedding,
  });
  final String token;
  final WeddingUser user;
  final Wedding? wedding;
}

class AuthNotifier extends Notifier<AuthState?> {
  @override
  AuthState? build() => null;

  WeddingRepository get _repo => ref.read(weddingRepositoryProvider);
  TokenStorage get _storage => ref.read(tokenStorageProvider);

  Future<void> restore() async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) return;
    try {
      final me = await _repo.me();
      state = AuthState(token: token, user: me.user, wedding: me.wedding);
    } catch (_) {
      await _storage.clearToken();
    }
  }

  Future<void> login(String phone, String password) async {
    final result = await _repo.login(phone, password);
    await _storage.saveToken(result.token);
    state = AuthState(token: result.token, user: result.user, wedding: result.wedding);
  }

  Future<void> register(String phone, String password, String name) async {
    final result = await _repo.register(phone, password, name);
    await _storage.saveToken(result.token);
    state = AuthState(token: result.token, user: result.user);
  }

  Future<void> refreshProfile() async {
    if (state == null) return;
    final me = await _repo.me();
    state = AuthState(token: state!.token, user: me.user, wedding: me.wedding);
  }

  void setWedding(Wedding wedding) {
    if (state == null) return;
    state = AuthState(
      token: state!.token,
      user: WeddingUser(
        id: state!.user.id,
        phone: state!.user.phone,
        name: state!.user.name,
        weddingId: wedding.id,
      ),
      wedding: wedding,
    );
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
    } catch (_) {}
    await _storage.clearToken();
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState?>(AuthNotifier.new);
final currentUserProvider = Provider<WeddingUser?>((ref) => ref.watch(authProvider)?.user);
final currentWeddingProvider = Provider<Wedding?>((ref) => ref.watch(authProvider)?.wedding);
