import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class PerfilDatasource {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> buscarPerfil() async {
    final usuario = _supabase.auth.currentUser;
    if (usuario == null) throw Exception('Usuário não autenticado');

    final perfil = await _supabase
        .from('perfis')
        .select('nome, cidade, tipo, nome_estabelecimento, foto_url, endereco, lat, lng')
        .eq('id', usuario.id)
        .single();

    final privado = await _supabase
        .from('perfis_privados')
        .select('telefone')
        .eq('id', usuario.id)
        .maybeSingle();

    return {
      'id': usuario.id,
      'email': usuario.email,
      'nome': perfil['nome'],
      'cidade': perfil['cidade'],
      'telefone': privado?['telefone'],
      'foto_url': perfil['foto_url'],
      'tipo': perfil['tipo'],
      'nome_estabelecimento': perfil['nome_estabelecimento'],
      'endereco': perfil['endereco'],
      'lat': perfil['lat'],
      'lng': perfil['lng'],
    };
    
  }

  Future<void> sair() async {
    await _supabase.auth.signOut();
  }

Future<void> atualizarPerfil({
  required String nome,
  required String telefone,
  required String cidade,
  bool ehBazar = false,
  String? endereco,
  double? lat,
  double? lng,
}) async {
  final usuarioId = _supabase.auth.currentUser?.id;
  if (usuarioId == null) throw Exception('Usuário não autenticado');

  await _supabase
    .from('perfis')
    .update({
      'nome': nome, 
      'cidade': cidade,
      if (ehBazar) ...{'endereco': endereco, 'lat': lat, 'lng': lng},
    }).eq('id', usuarioId);

  await _supabase
    .from('perfis_privados')
    .upsert({'id': usuarioId, 'telefone': telefone});
}


Future<String> uploadFotoPerfil(String caminhoLocal) async {
  final usuarioId = _supabase.auth.currentUser?.id;
  if (usuarioId == null) throw Exception('Usuário não autenticado');

  final arquivo = File(caminhoLocal);
  final extensao = caminhoLocal.split('.').last;
  final caminhoStorage = '$usuarioId/avatar.$extensao';

  await _supabase.storage
      .from('fotos-perfil')
      .upload(caminhoStorage, arquivo,
          fileOptions: const FileOptions(upsert: true));

  final url = _supabase.storage
      .from('fotos-perfil')
      .getPublicUrl(caminhoStorage);

  await _supabase.from('perfis').update({
    'foto_url': url,
  }).eq('id', usuarioId);

  return url;
  }
}