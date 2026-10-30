import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushService {
  final _fcm = FirebaseMessaging.instance;
  final _supabase = Supabase.instance.client;
  StreamSubscription<String>? _refreshSub;

  Future<void> registrar() async {
    if (_supabase.auth.currentUser == null) return;

    final permissao = await _fcm.requestPermission();
    if (permissao.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('Permissão de notificação negada');
      return;
    }

    final token = await _fcm.getToken();
    if (token == null) return;
    await _salvarToken(token);

    await _refreshSub?.cancel();
    _refreshSub = _fcm.onTokenRefresh.listen(_salvarToken);
  }

  Future<void> _salvarToken(String token) async {
    try {
      await _supabase.rpc('registrar_dispositivo', params: {'p_token': token});
      debugPrint('Token FCM salvo');
    } catch (e) {
      debugPrint('Erro ao salvar token: $e');
    }
  }

  Future<void> remover() async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await _supabase.from('dispositivos').delete().eq('token', token);
      }
      await _refreshSub?.cancel();
    } catch (e) {
      debugPrint('Erro ao remover token: $e');
    }
  }
}