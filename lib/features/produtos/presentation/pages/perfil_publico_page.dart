import 'dart:io';
import 'package:flutter/material.dart';
import 'package:replaykids/core/injector/injector.dart';
import 'package:replaykids/core/theme/app_colors.dart';
import 'package:replaykids/features/anuncio/domain/entities/anuncio_entity.dart';
import 'package:replaykids/features/anuncio/domain/repositories/anuncio_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:replaykids/features/produtos/presentation/pages/detalhes_page.dart';
import 'package:replaykids/core/widgets/foto_widget.dart';

class PerfilPublicoPage extends StatefulWidget {
  final String usuarioId;
  final String nome;

  const PerfilPublicoPage({
    super.key,
    required this.usuarioId,
    required this.nome,
  });

  @override
  State<PerfilPublicoPage> createState() => _PerfilPublicoPageState();
}

class _PerfilPublicoPageState extends State<PerfilPublicoPage> {
  final _anuncioRepository = injector.get<AnuncioRepository>();
  Map<String, dynamic>? _perfil;
  List<AnuncioEntity> _anuncios = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final perfil = await Supabase.instance.client
          .from('perfis')
          .select()
          .eq('id', widget.usuarioId)
          .single();

      final todos = await _anuncioRepository.listar();
      final anuncios = todos
          .where((a) => a.usuarioId == widget.usuarioId)
          .toList();

      setState(() {
        _perfil = perfil;
        _anuncios = anuncios;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.c50,
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.c500))
          : CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Container(
                    color: AppColors.c100,
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 28),
                    child: Column(
                      children: [
                        
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.maybePop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: AppColors.c200,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_back,
                                  size: 18, color: AppColors.c800),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(
                            color: AppColors.c200,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.person_rounded,
                              size: 48, color: AppColors.c600),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          _perfil?['nome'] ?? widget.nome,
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
                            if (_perfil?['cidade'] != null)
                              Text(
                                _perfil!['cidade'] as String,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.neutral600,
                                ),
                              ),
                            if (_perfil?['cidade'] != null)
                              const Text(' • ',
                                  style:
                                      TextStyle(color: AppColors.neutral400)),
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
                      'Anúncios de ${_perfil?['nome'] ?? widget.nome}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral800,
                      ),
                    ),
                  ),
                ),

                _anuncios.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          child: const Text(
                            'Nenhum anúncio publicado.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.neutral500,
                            ),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => _CardAnuncio(
                                anuncio: _anuncios[i]),
                            childCount: _anuncios.length,
                          ),
                        ),
                      ),
              ],
            ),
    );
  }
}

class _CardAnuncio extends StatelessWidget {
  final AnuncioEntity anuncio;
  const _CardAnuncio({required this.anuncio});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetalhesPage(anuncio: anuncio)),
      ),
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
                    top: Radius.circular(16)),
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