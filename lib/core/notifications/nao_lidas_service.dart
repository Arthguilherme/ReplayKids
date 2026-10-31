import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NaoLidasService {
  final _supabase = Supabase.instance.client;
  final ValueNotifier<int> total = ValueNotifier(0);
  RealtimeChannel? _canal;

  Future<void> iniciar() async {
    await atualizar();
    await _canal?.unsubscribe();
    _canal = _supabase
        .channel('nao_lidas')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'mensagens',
          callback: (_) => atualizar(),
        )
        .subscribe();
  }

  Future<void> atualizar() async {
    final meuId = _supabase.auth.currentUser?.id;
    if (meuId == null) {
      total.value = 0;
      return;
    }
    final resposta = await _supabase
        .from('mensagens')
        .select('id')
        .eq('lida', false)
        .neq('remetente_id', meuId);
    total.value = (resposta as List).length;
  }

  Future<void> parar() async {
    await _canal?.unsubscribe();
    _canal = null;
    total.value = 0;
  }
}