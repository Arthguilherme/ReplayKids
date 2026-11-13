import 'package:flutter/material.dart';
import 'package:replaykids/core/theme/app_colors.dart';

class DiretrizesPage extends StatelessWidget {
  const DiretrizesPage({super.key});

  static const _emailContato = 'arth.ssg@gmail.com';

  static const _secoes = <_Secao>[
    _Secao(
      titulo: 'Diretrizes da comunidade',
      itens: [
        'A ReplayKids é um hub de divulgação de artigos infantis seminovos '
            'do litoral do Paraná. A plataforma não realiza vendas, '
            'pagamentos nem entregas: a retirada ou a entrega é combinada '
            'diretamente entre os usuários, pelo chat.',
        'Publique apenas artigos infantis em boas condições e higienizados.',
        'Use fotos reais do item e descreva o estado de conservação com '
            'sinceridade.',
        'Seja respeitoso nas conversas. Mensagens com conteúdo inadequado '
            'não são enviadas.',
        'Combine a retirada dos itens em locais seguros e movimentados.',
        'Você pode editar ou excluir os seus anúncios a qualquer momento.',
      ],
    ),
    _Secao(
      titulo: 'Termos de Uso',
      itens: [
        'O uso do aplicativo é gratuito e a ReplayKids não cobra taxas '
            'sobre os anúncios.',
        'Para publicar anúncios e conversar com outros usuários, é '
            'necessário criar uma conta com informações verdadeiras. Cada '
            'e-mail pode ter apenas uma conta.',
        'Cada anúncio deve ser vinculado a um município do litoral do '
            'Paraná.',
        'Os anúncios e as negociações são de responsabilidade dos usuários '
            'envolvidos.',
      ],
    ),
    _Secao(
      titulo: 'Política de Privacidade',
      itens: [
        'Seguimos a Lei Geral de Proteção de Dados Pessoais (LGPD, Lei nº '
            '13.709/2018).',
        'Coletamos nome, e-mail, telefone, município, tipo de conta, foto de '
            'perfil, fotos dos anúncios, mensagens do chat e o identificador '
            'do dispositivo usado para enviar notificações.',
        'Usamos esses dados para criar e manter a sua conta, exibir os seus '
            'anúncios, permitir a comunicação entre usuários e avisar sobre '
            'novas mensagens.',
        'Os dados ficam armazenados em um serviço de banco de dados na '
            'nuvem e não são vendidos a terceiros.',
        'Você pode solicitar acesso, correção ou exclusão dos seus dados '
            'pelo e-mail $_emailContato.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.c50,
      appBar: AppBar(
        backgroundColor: AppColors.c50,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.neutral700),
        title: const Text(
          'Diretrizes e ajuda',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          for (final secao in _secoes) ...[
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 10),
              child: Text(
                secao.titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.c700,
                ),
              ),
            ),
            for (final item in secao.itens)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6, right: 10),
                      child: Icon(Icons.circle,
                          size: 6, color: AppColors.c400),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.neutral700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Secao {
  final String titulo;
  final List<String> itens;
  const _Secao({required this.titulo, required this.itens});
}