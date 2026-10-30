import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:replaykids/core/routes/app_router.dart';

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

  int? _conversaPendente;

/// Chamar uma vez no main(), depois do setupInjector().
Future<void> iniciarListeners() async {
  // App em segundo plano: abre direto
  FirebaseMessaging.onMessageOpenedApp.listen(_tratarMensagem);

  // App fechado: guarda para abrir quando a MainPage estiver pronta
  final inicial = await _fcm.getInitialMessage();
  if (inicial != null) {
    _conversaPendente = int.tryParse(inicial.data['conversa_id'] ?? '');
  }
}

/// Chamada pela MainPage ao iniciar.
void abrirPendente() {
  final id = _conversaPendente;
  if (id == null) return;
  _conversaPendente = null;
  _abrirConversa(id);
}

void _tratarMensagem(RemoteMessage mensagem) {
  final id = int.tryParse(mensagem.data['conversa_id'] ?? '');
  if (id != null) _abrirConversa(id);
}

Future<void> _abrirConversa(int conversaId) async {
 
  var titulo = 'Chat';
  try {
    final conversa = await _supabase
        .from('conversas')
        .select('anuncios(titulo)')
        .eq('id', conversaId)
        .single();
    final anuncio = conversa['anuncios'];
    if (anuncio is Map && anuncio['titulo'] != null) {
      titulo = anuncio['titulo'] as String;
    }
  } catch (e) {
    debugPrint('Erro ao buscar conversa: $e');
  }
  AppRouter.router.push('/chat/$conversaId', extra: titulo);
}

}