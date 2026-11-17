import 'package:supabase_flutter/supabase_flutter.dart';

class RecuperacaoSenhaDatasource {
  final _supabase = Supabase.instance.client;

  Future<void> enviarCodigo(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> verificarCodigo(String email, String codigo) async {
    final r = await _supabase.auth.verifyOTP(
      type: OtpType.recovery,
      email: email,
      token: codigo,
    );
    if (r.session == null) throw Exception('Código inválido ou expirado');
  }

  Future<void> definirNovaSenha(String senha) async {
    await _supabase.auth.updateUser(UserAttributes(password: senha));
  }
}