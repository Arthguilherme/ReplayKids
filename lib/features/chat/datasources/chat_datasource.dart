import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatDatasource {
  final _supabase = Supabase.instance.client;

  Future<int> buscarOuCriarConversa({
    required String vendedorId,
    required int anuncioId,
  }) async {
    final compradorId = _supabase.auth.currentUser?.id;
    if (compradorId == null) throw Exception('Usuário não autenticado');

    final existente = await _supabase
        .from('conversas')
        .select('id')
        .eq('comprador_id', compradorId)
        .eq('vendedor_id', vendedorId)
        .eq('anuncio_id', anuncioId)
        .maybeSingle();

    if (existente != null) return existente['id'] as int;

    final nova = await _supabase.from('conversas').insert({
      'comprador_id': compradorId,
      'vendedor_id': vendedorId,
      'anuncio_id': anuncioId,
    }).select('id').single();

    return nova['id'] as int;
  }

  Future<List<Map<String, dynamic>>> listarConversas() async {
    final usuarioId = _supabase.auth.currentUser?.id;
    if (usuarioId == null) return [];

    final resultado = await _supabase
        .from('conversas')
        .select('''
          id,
          anuncio_id,
          comprador_id,
          vendedor_id,
          created_at,
          anuncios(titulo, fotos),
          mensagens(texto, created_at, remetente_id)
        ''')
        .or('comprador_id.eq.$usuarioId,vendedor_id.eq.$usuarioId')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(resultado);
  }

  Future<List<Map<String, dynamic>>> listarMensagens(int conversaId) async {
    final resultado = await _supabase
        .from('mensagens')
        .select()
        .eq('conversa_id', conversaId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(resultado);
  }

  Future<void> enviarMensagem({
    required int conversaId,
    required String texto,
  }) async {
    final remetenteId = _supabase.auth.currentUser?.id;
    if (remetenteId == null) throw Exception('Usuário não autenticado');

    await _supabase.from('mensagens').insert({
      'conversa_id': conversaId,
      'remetente_id': remetenteId,
      'texto': texto,
    });
  }

  RealtimeChannel escutarMensagens({
    required int conversaId,
    required void Function(Map<String, dynamic>) onNovaMensagem,
  }) {
    return _supabase
        .channel('mensagens_$conversaId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'mensagens',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversa_id',
            value: conversaId,
          ),
          callback: (payload) {
            debugPrint('Nova mensagem recebida: ${payload.newRecord}');
            onNovaMensagem(payload.newRecord);
          },
        )
        .subscribe();
  }
}