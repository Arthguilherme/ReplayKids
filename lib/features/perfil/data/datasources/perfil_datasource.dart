import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilDatasource {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> buscarPerfil() async {
    final usuario = _supabase.auth.currentUser;
    if (usuario == null) throw Exception('Usuário não autenticado');

    final perfil = await _supabase
        .from('perfis')
        .select()
        .eq('id', usuario.id)
        .single();

    return {
      'id': usuario.id,
      'email': usuario.email,
      'nome': perfil['nome'],
      'cidade': perfil['cidade'],
      'telefone': perfil['telefone'],
    };
  }

  Future<void> sair() async {
    await _supabase.auth.signOut();
  }
}