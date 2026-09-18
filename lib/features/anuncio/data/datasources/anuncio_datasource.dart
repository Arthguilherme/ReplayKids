import 'package:replaykids/core/database/database_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/anuncio_model.dart';

abstract class AnuncioDatasource {
  Future<List<AnuncioModel>> listar();
  Future<void> publicar(AnuncioModel anuncio);
  Future<void> deletar(int id);
}

class AnuncioDatasourceSqlite implements AnuncioDatasource {
  @override
  Future<List<AnuncioModel>> listar() async {
    final db = await DatabaseHelper.database;
    final resultado = await db.query(
      'anuncios',
      orderBy: 'id DESC',
    );
    return resultado.map((row) => AnuncioModel.fromMap(row)).toList();
  }

  @override
  Future<void> publicar(AnuncioModel anuncio) async {
    final db = await DatabaseHelper.database;
    await db.insert('anuncios', anuncio.toMap());
  }

  @override
  Future<void> deletar(int id) async {
    final db = await DatabaseHelper.database;
    await db.delete('anuncios', where: 'id = ?', whereArgs: [id]);
  }
}

class AnuncioDatasourceSupabase implements AnuncioDatasource {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<AnuncioModel>> listar() async {
    final resultado = await _supabase
        .from('anuncios')
        .select()
        .order('created_at', ascending: false);

    return (resultado as List).map((row) => AnuncioModel.fromMap(row)).toList();
  }

  @override
  Future<void> publicar(AnuncioModel anuncio) async {
    final usuario = _supabase.auth.currentUser;
    if (usuario == null) throw Exception('Usuário não autenticado');

    await _supabase.from('anuncios').insert({
      'usuario_id': usuario.id,
      'titulo': anuncio.titulo,
      'descricao': anuncio.descricao,
      'condicao': anuncio.condicao,
      'categoria': anuncio.categoria,
      'faixa_etaria': anuncio.faixaEtaria,
      'is_venda': anuncio.isVenda,
      'preco': anuncio.preco,
      'fotos': anuncio.fotos,
    });
  }

  @override
  Future<void> deletar(int id) async {
    await _supabase.from('anuncios').delete().eq('id', id);
  }
}
