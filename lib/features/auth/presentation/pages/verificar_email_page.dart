import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:replaykids/core/injector/injector.dart';
import 'package:replaykids/core/routes/app_router.dart';
import 'package:replaykids/core/theme/app_colors.dart';
import 'package:replaykids/features/auth/data/datasources/verificacao_email_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerificarEmailPage extends StatefulWidget {
  final String email;
  const VerificarEmailPage({super.key, required this.email});

  @override
  State<VerificarEmailPage> createState() => _VerificarEmailPageState();
}

class _VerificarEmailPageState extends State<VerificarEmailPage> {
  final _ds = injector.get<VerificacaoEmailDatasource>();
  final _codigoController = TextEditingController();
  Timer? _timer;
  int _cooldown = 0;
  bool _carregando = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _iniciarCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codigoController.dispose();
    super.dispose();
  }

  void _iniciarCooldown() {
    setState(() => _cooldown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _cooldown--);
      if (_cooldown <= 0) t.cancel();
    });
  }

  Future<void> _confirmar() async {
    final codigo = _codigoController.text.trim();
    if (codigo.length < 6) {
      setState(() => _erro = 'Digite o código que enviamos por e-mail');
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await _ds.verificar(widget.email, codigo);
      if (!mounted) return;
      context.go(AppRouter.feed);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.statusCode == '429'
          ? 'Muitas tentativas. Aguarde um pouco.'
          : 'Código inválido ou expirado.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _erro = 'Não foi possível confirmar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _reenviar() async {
    if (_cooldown > 0) return;
    try {
      await _ds.reenviar(widget.email);
      _iniciarCooldown();
      if (!mounted) return;
      setState(() => _erro = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Novo código enviado')),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.statusCode == '429'
          ? 'Aguarde um minuto para pedir outro código.'
          : 'Não foi possível reenviar o código.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.c50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 60, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.c500,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.mark_email_unread_outlined,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(height: 20),
              const Text(
                'Confirme seu e-mail',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Text(
                'Enviamos um código para ${widget.email}. '
                'Se não encontrar, olhe a caixa de spam.',
                style: const TextStyle(color: AppColors.neutral600, height: 1.4),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _codigoController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••••',
                  filled: true,
                  fillColor: Colors.white,
                  errorText: _erro,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.neutral200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: AppColors.c400, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _confirmar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.c500,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _carregando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Confirmar',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _cooldown > 0 ? null : _reenviar,
                  child: Text(
                    _cooldown > 0
                        ? 'Reenviar código em ${_cooldown}s'
                        : 'Reenviar código',
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: () => context.go(AppRouter.login),
                  child: const Text('Voltar ao login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}