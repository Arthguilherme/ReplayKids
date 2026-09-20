import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class FavoritosDatasource {
  final _supabase = Supabase.instance.client;

  Future<List<int>> listarIds() async {
  final usuarioId = _supabase.auth.currentUser?.id;
  debugPrint('Usuario buscando favoritos: $usuarioId');
  if (usuarioId == null) return [];

  final resultado = await _supabase
      .from('favoritos')
      .select('anuncio_id')
      .eq('usuario_id', usuarioId);

  debugPrint('Resultado favoritos: $resultado');

  return (resultado as List)
      .map((row) => row['anuncio_id'] as int)
      .toList();
}

  Future<void> favoritar(int anuncioId) async {
    final usuarioId = _supabase.auth.currentUser?.id;
    if (usuarioId == null) throw Exception('Usuário não autenticado');

    await _supabase.from('favoritos').insert({
      'usuario_id': usuarioId,
      'anuncio_id': anuncioId,
    });
  }

  Future<void> desfavoritar(int anuncioId) async {
    final usuarioId = _supabase.auth.currentUser?.id;
    if (usuarioId == null) throw Exception('Usuário não autenticado');

    await _supabase
        .from('favoritos')
        .delete()
        .eq('usuario_id', usuarioId)
        .eq('anuncio_id', anuncioId);
  }

  Future<bool> ehFavoritado(int anuncioId) async {
    final usuarioId = _supabase.auth.currentUser?.id;
    if (usuarioId == null) return false;

    final resultado = await _supabase
        .from('favoritos')
        .select()
        .eq('usuario_id', usuarioId)
        .eq('anuncio_id', anuncioId);

    return (resultado as List).isNotEmpty;
  }
}