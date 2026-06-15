import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_router.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/labeled_field.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _telefoneController = TextEditingController();

  String _cidadeSelecionada = 'Matinhos, PR';
  bool _aceitouTermos = false;

  static const _cidades = [
    'Paranaguá, PR',
    'Matinhos, PR',
    'Pontal do Paraná, PR',
    'Guaratuba, PR',
    'Antonina, PR',
    'Morretes, PR',
    'Guaraqueçaba, PR',
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.c50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Botão voltar
              InkWell(
                onTap: () => context.go(AppRouter.login),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.c100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, size: 18, color: AppColors.c800),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Criar conta',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              const Text(
                'Leva menos de um minuto.',
                style: TextStyle(color: AppColors.neutral600, fontSize: 13),
              ),
              const SizedBox(height: 22),

              LabeledField(
                label: 'Nome completo',
                hint: 'Escreva seu Nome aqui',
                icon: Icons.person_outline,
                controller: _nomeController,
              ),
              const SizedBox(height: 10),

              LabeledField(
                label: 'E-mail',
                hint: 'Seu@email.com',
                icon: Icons.mail_outline,
                controller: _emailController,
                keyboard: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),

              LabeledField(
                label: 'Senha',
                hint: 'Mínimo 8 caracteres',
                icon: Icons.lock_outline,
                controller: _senhaController,
                obscure: true,
              ),
              const SizedBox(height: 10),

              // Dropdown de cidade
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 6),
                    child: Text(
                      'Município do litoral',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral700,
                      ),
                    ),
                  ),
                  InputDecorator(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.location_on_outlined,
                          size: 18, color: AppColors.neutral400),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.neutral200),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _cidadeSelecionada,
                        isExpanded: true,
                        icon: const Icon(Icons.expand_more, color: AppColors.neutral400),
                        items: _cidades
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c, style: const TextStyle(fontSize: 13)),
                                ))
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            _cidadeSelecionada = v ?? _cidadeSelecionada;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              LabeledField(
                label: 'Número de telefone',
                hint: '(41) 99999-0000',
                icon: Icons.phone_outlined,
                controller: _telefoneController,
                keyboard: TextInputType.phone,
              ),
              const SizedBox(height: 14),

              // Checkbox de termos
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _aceitouTermos = !_aceitouTermos;
                      });
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: _aceitouTermos ? AppColors.c500 : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _aceitouTermos ? AppColors.c500 : AppColors.neutral300,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: _aceitouTermos
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _aceitouTermos = !_aceitouTermos;
                        });
                      },
                      child: const Text.rich(
                        TextSpan(
                          style: TextStyle(fontSize: 11, color: AppColors.neutral600, height: 1.4),
                          children: [
                            TextSpan(text: 'Li e aceito os '),
                            TextSpan(
                              text: 'Termos de Uso',
                              style: TextStyle(
                                color: AppColors.c700,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(text: ' e a '),
                            TextSpan(
                              text: 'Política de Privacidade',
                              style: TextStyle(
                                color: AppColors.c700,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Botão criar conta
              SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint('Nome: ${_nomeController.text}');
                    debugPrint('Email: ${_emailController.text}');
                    debugPrint('Senha: ${_senhaController.text}');
                    debugPrint('Telefone: ${_telefoneController.text}');
                    debugPrint('Cidade: $_cidadeSelecionada');
                    debugPrint('Aceitou termos: $_aceitouTermos');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.c500,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Criar conta',
                    style: TextStyle(fontWeight: FontWeight.w600),
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