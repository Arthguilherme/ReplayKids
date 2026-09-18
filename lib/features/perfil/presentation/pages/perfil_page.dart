import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:replaykids/core/injector/injector.dart';
import 'package:replaykids/core/routes/app_router.dart';
import 'package:replaykids/core/theme/app_colors.dart';
import 'package:replaykids/features/anuncio/domain/entities/anuncio_entity.dart';
import 'package:replaykids/features/anuncio/domain/repositories/anuncio_repository.dart';
import 'package:replaykids/features/perfil/data/datasources/perfil_datasource.dart';
import 'dart:io';
import 'package:replaykids/features/produtos/presentation/pages/detalhes_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _perfilDatasource = injector.get<PerfilDatasource>();
  final _anuncioRepository = injector.get<AnuncioRepository>();

  Map<String, dynamic>? _perfil;
  List<AnuncioEntity> _meusAnuncios = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final perfil = await _perfilDatasource.buscarPerfil();
      final todos = await _anuncioRepository.listar();
      final usuarioId = Supabase.instance.client.auth.currentUser?.id;
      final meus = todos.where((a) => a.usuarioId == usuarioId).toList();
      setState(() {
        _perfil = perfil;
        _meusAnuncios = meus;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
    }
  }

  Future<void> _sair() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      await _perfilDatasource.sair();
      if (mounted) context.go(AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        backgroundColor: AppColors.c50,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.c500),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.c50,
      body: RefreshIndicator(
        color: AppColors.c500,
        onRefresh: _carregar,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.c100,
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        color: AppColors.c200,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: AppColors.c600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      _perfil?['nome'] ?? 'Usuário',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.c900,
                      ),
                    ),
                    const SizedBox(height: 4),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _perfil?['cidade'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.neutral600,
                          ),
                        ),
                        if (_perfil?['cidade'] != null) ...[
                          const Text(' • ',
                              style:
                                  TextStyle(color: AppColors.neutral400)),
                        ],
                        const Icon(Icons.star_rounded,
                            size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        const Text(
                          '4.9',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  'Meus Anúncios',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral800,
                  ),
                ),
              ),
            ),

            _meusAnuncios.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: const Text(
                        'Você ainda não publicou nenhum anúncio.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.neutral500,
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _MeuAnuncioCard(
                          anuncio: _meusAnuncios[i],
                          onDeletado: _carregar,
                        ),
                        childCount: _meusAnuncios.length,
                      ),
                    ),
                  ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Column(
                  children: [
                    _OpcaoItem(
                      icon: Icons.settings_outlined,
                      label: 'Configurações',
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),
                    _OpcaoItem(
                      icon: Icons.help_outline_rounded,
                      label: 'Central de Ajuda',
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),
                    _OpcaoItem(
                      icon: Icons.logout_rounded,
                      label: 'Sair',
                      onTap: _sair,
                      vermelho: true,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeuAnuncioCard extends StatelessWidget {
  final AnuncioEntity anuncio;
  final VoidCallback onDeletado;
  const _MeuAnuncioCard({required this.anuncio, required this.onDeletado});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetalhesPage(anuncio: anuncio),
        ),
      ).then((_) => onDeletado()),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neutral100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: anuncio.fotos.isEmpty
                    ? Container(
                        color: AppColors.c100,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_outlined,
                            color: AppColors.c400, size: 36),
                      )
                    : Image.file(
                        File(anuncio.fotos.first),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anuncio.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    anuncio.isVenda ? 'R\$ ${anuncio.preco}' : 'Doação',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.c700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpcaoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool vermelho;

  const _OpcaoItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.vermelho = false,
  });

  @override
  Widget build(BuildContext context) {
    final cor = vermelho ? Colors.red : AppColors.neutral700;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.neutral100),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: cor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: cor,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: AppColors.neutral400),
          ],
        ),
      ),
    );
  }
}