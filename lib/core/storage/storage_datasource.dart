import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class StorageDatasource {
  final _supabase = Supabase.instance.client;

  Future<String> uploadFoto(String caminhoLocal) async {
    final arquivo = File(caminhoLocal);
    final extensao = path.extension(caminhoLocal);
    final nomeArquivo =
        '${DateTime.now().millisecondsSinceEpoch}$extensao';

    final usuarioId = _supabase.auth.currentUser?.id;
    if (usuarioId == null) throw Exception('Usuário não autenticado');

    final caminhoStorage = '$usuarioId/$nomeArquivo';

    await _supabase.storage
        .from('fotos-anuncios')
        .upload(caminhoStorage, arquivo);

    final url = _supabase.storage
        .from('fotos-anuncios')
        .getPublicUrl(caminhoStorage);

    return url;
  }
}