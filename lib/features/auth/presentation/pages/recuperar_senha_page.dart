import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:replaykids/core/injector/injector.dart';
import 'package:replaykids/core/routes/app_router.dart';
import 'package:replaykids/core/theme/app_colors.dart';
import 'package:replaykids/core/utils/validators.dart';
import 'package:replaykids/core/widgets/labeled_field.dart';
import 'package:replaykids/features/auth/data/datasources/recuperacao_senha_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum _Etapa { email, codigo, novaSenha }

class RecuperarSenhaPage extends StatefulWidget {
  final String emailInicial;
  const RecuperarSenhaPage({super.key, this.emailInicial = ''});

  @override
  State<RecuperarSenhaPage> createState() => _RecuperarSenhaPageState();
}

class _RecuperarSenhaPageState extends State<RecuperarSenhaPage> {
  final _ds = injector.get<RecuperacaoSenhaDatasource>();
  late final _emailController =
      TextEditingController(text: widget.emailInicial);
  final _codigoController = TextEditingController();
  final _senhaController = TextEditingController();

  _Etapa _etapa = _Etapa.email;
  bool _carregando = false;
  bool _senhaVisivel = false;
  String? _erro;
  Timer? _timer;
  int _cooldown = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _codigoController.dispose();
    _senhaController.dispose();
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

  String _mensagem(AuthApiException e, String padrao) {
    switch (e.code) {
      case 'over_email_send_rate_limit':
      case 'over_request_rate_limit':
        return 'Muitas tentativas. Aguarde um pouco e tente de novo.';
      case 'otp_expired':
        return 'Código inválido ou expirado.';
      case 'same_password':
        return 'A nova senha precisa ser diferente da anterior.';
      case 'weak_password':
        return 'Senha muito fraca. Use ao menos 8 caracteres, com letras e números.';
      default:
        return padrao;
    }
  }

  Future<void> _executar(
    Future<void> Function() acao, {
    required String padrao,
  }) async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      await acao();
    } on AuthApiException catch (e) {
      if (mounted) setState(() => _erro = _mensagem(e, padrao));
    } catch (_) {
      if (mounted) setState(() => _erro = 'Sem conexão. Tente novamente.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _enviarCodigo({bool reenvio = false}) async {
    final email = _emailController.text.trim();
    final erroEmail = Validators.email(email);
    if (erroEmail != null) {
      setState(() => _erro = erroEmail);
      return;
    }
    await _executar(() async {
      await _ds.enviarCodigo(email);
      if (!mounted) return;
      _iniciarCooldown();
      setState(() => _etapa = _Etapa.codigo);
      if (reenvio) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Novo código enviado')),
        );
      }
    }, padrao: 'Não foi possível enviar o código. Tente novamente.');
  }

  Future<void> _verificarCodigo() async {
    final codigo = _codigoController.text.trim();
    if (codigo.length < 6) {
      setState(() => _erro = 'Digite o código que enviamos por e-mail');
      return;
    }
    await _executar(() async {
      await _ds.verificarCodigo(_emailController.text.trim(), codigo);
      if (!mounted) return;
      setState(() => _etapa = _Etapa.novaSenha);
    }, padrao: 'Código inválido ou expirado.');
  }

  Future<void> _salvarSenha() async {
    final erro = Validators.senha(_senhaController.text);
    if (erro != null) {
      setState(() => _erro = erro);
      return;
    }
    await _executar(() async {
      await _ds.definirNovaSenha(_senhaController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha alterada com sucesso!'),
          backgroundColor: AppColors.c600,
        ),
      );
      context.go(AppRouter.feed);
    }, padrao: 'Não foi possível salvar a senha. Tente novamente.');
  }

  void _acaoPrincipal() {
    switch (_etapa) {
      case _Etapa.email:
        _enviarCodigo();
        break;
      case _Etapa.codigo:
        _verificarCodigo();
        break;
      case _Etapa.novaSenha:
        _salvarSenha();
        break;
    }
  }

  Widget _campo() {
    switch (_etapa) {
      case _Etapa.email:
        return LabeledField(
          label: 'E-mail',
          hint: 'exemplo@email.com',
          icon: Icons.mail_outline,
          controller: _emailController,
          keyboard: TextInputType.emailAddress,
        );
      case _Etapa.codigo:
        return TextField(
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
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.neutral200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.c400, width: 1.5),
            ),
          ),
        );
      case _Etapa.novaSenha:
        return LabeledField(
          label: 'Nova senha',
          hint: 'Mínimo 8 caracteres',
          icon: Icons.lock_outline,
          controller: _senhaController,
          obscure: !_senhaVisivel,
          suffixIcon: IconButton(
            icon: Icon(
              _senhaVisivel ? Icons.visibility_off : Icons.visibility,
              color: AppColors.c400,
              size: 20,
            ),
            onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titulo = switch (_etapa) {
      _Etapa.email => 'Recuperar senha',
      _Etapa.codigo => 'Digite o código',
      _Etapa.novaSenha => 'Crie uma nova senha',
    };
    final subtitulo = switch (_etapa) {
      _Etapa.email =>
        'Informe o e-mail da sua conta e enviaremos um código para você.',
      _Etapa.codigo =>
        'Se ${_emailController.text.trim()} estiver cadastrado, enviamos um código. Confira também o spam.',
      _Etapa.novaSenha =>
        'Escolha uma senha com pelo menos 8 caracteres, com letras e números.',
    };
    final rotuloBotao = switch (_etapa) {
      _Etapa.email => 'Enviar código',
      _Etapa.codigo => 'Confirmar código',
      _Etapa.novaSenha => 'Salvar nova senha',
    };

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
                child: const Icon(Icons.lock_reset_outlined,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(height: 20),
              Text(
                titulo,
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Text(
                subtitulo,
                style: const TextStyle(
                    color: AppColors.neutral600, height: 1.4),
              ),
              const SizedBox(height: 28),
              _campo(),
              if (_erro != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _erro!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _acaoPrincipal,
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
                      : Text(rotuloBotao,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              if (_etapa == _Etapa.codigo) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: _cooldown > 0 || _carregando
                        ? null
                        : () => _enviarCodigo(reenvio: true),
                    child: Text(_cooldown > 0
                        ? 'Reenviar código em ${_cooldown}s'
                        : 'Reenviar código'),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() {
                      _etapa = _Etapa.email;
                      _codigoController.clear();
                      _erro = null;
                    }),
                    child: const Text('Trocar e-mail'),
                  ),
                ),
              ],
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