import 'package:supabase_flutter/supabase_flutter.dart';

const EmailNaoConfirmado = 'email_nao_confirmado';

class VerificacaoEmailDatasource {
  final _supabase = Supabase.instance.client;

  Future<void> verificar(String email, String codigo) async {
    final r = await _supabase.auth.verifyOTP(
      type: OtpType.signup,
      email: email,
      token: codigo,
    );
    if (r.session == null) throw Exception('Código inválido ou expirado');
  }

  Future<void> reenviar(String email) async {
    await _supabase.auth.resend(type: OtpType.signup, email: email);
  }
}