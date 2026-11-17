import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../../core/injector/injector.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../controllers/login_controller.dart';
import 'package:replaykids/features/auth/data/datasources/verificacao_email_datasource.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _senhaVisivel = false;

  final _loginController = injector.get<LoginController>();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    await _loginController.login(
      _emailController.text.trim(),
      _senhaController.text,
    );

    if (_loginController.status.value == LoginStatus.sucesso && mounted) {
      context.go(AppRouter.feed);
    } else if (_loginController.mensagemErro.value == EmailNaoConfirmado &&
        mounted) {
      final email = _emailController.text.trim();
      try {
        await injector.get<VerificacaoEmailDatasource>().reenviar(email);
      } catch (_) {}
      if (mounted) context.go(AppRouter.verificarEmail, extra: email);
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
                alignment: Alignment.center,
                child: const Text(
                  'RK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Bem-vindo de volta',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, height: 1.15),
              ),
              const SizedBox(height: 12),
              const Text(
                'Dê uma nova vida aos itens que seus pequenos não usam mais.',
                style: TextStyle(color: AppColors.neutral600),
              ),

              const SizedBox(height: 28),

              LabeledField(
                label: 'E-mail',
                hint: 'exemplo@email.com',
                icon: Icons.mail_outline,
                controller: _emailController,
                keyboard: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              LabeledField(
                label: 'Senha',
                hint: '••••••••',
                icon: Icons.lock_outline,
                controller: _senhaController,
                obscure: !_senhaVisivel,
                suffixIcon: IconButton(
                  icon: Icon(
                    _senhaVisivel ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.c400,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _senhaVisivel = !_senhaVisivel);
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go(
                    AppRouter.recuperarSenha,
                    extra: _emailController.text.trim(),
                  ),
                  child: const Text(
                    'Esqueci minha senha',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.c700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Watch((context) {
                final erro = _loginController.mensagemErro.value;
                if (erro == null || erro == EmailNaoConfirmado) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    erro,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                );
              }),

              const SizedBox(height: 16),

              Watch((context) {
                final carregando = _loginController.status.value == LoginStatus.carregando;
                return SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: carregando ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.c500,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: carregando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Entrar',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                );
              }),

              const SizedBox(height: 8),

              Center(
                child: GestureDetector(
                  onTap: () => context.go(AppRouter.cadastro),
                  child: RichText(
                    text: const TextSpan(
                      text: 'Não tem conta? ',
                      style: TextStyle(color: AppColors.neutral500, fontSize: 12),
                      children: [
                        TextSpan(
                          text: 'Cadastre-se',
                          style: TextStyle(
                            color: AppColors.c700,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}