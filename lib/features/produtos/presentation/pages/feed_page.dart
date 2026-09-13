import 'dart:io';
import 'package:replaykids/features/anuncio/presentation/pages/publish_step1_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:replaykids/core/injector/injector.dart';
import 'package:replaykids/core/routes/app_router.dart';
import 'package:replaykids/core/theme/app_colors.dart';
import 'package:replaykids/features/anuncio/domain/entities/anuncio_entity.dart';
import 'package:replaykids/features/anuncio/domain/repositories/anuncio_repository.dart';
import 'package:replaykids/features/produtos/presentation/pages/detalhes_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _repository = injector.get<AnuncioRepository>();
  String _categoriaSelecionada = 'Todos';
  List<AnuncioEntity> _anuncios = [];

  final _categorias = [
    'Todos',
    'Brinquedos',
    'Roupas',
    'Carrinhos',
    'Móveis',
    'Livros',
    'Calçados',
    'Acessórios',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();
    _carregarAnuncios();
  }

  Future<void> _carregarAnuncios() async {
    final anuncios = await _repository.listar();
    setState(() => _anuncios = anuncios);
  }

  List<AnuncioEntity> get _anunciosFiltrados {
    if (_categoriaSelecionada == 'Todos') return _anuncios;
    return _anuncios
        .where((a) => a.categoria == _categoriaSelecionada)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.c50,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'ReplayKids',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.c900,
                        ),
                      ),
                      Text(
                        'Litoral do Paraná',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.c700,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categorias.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = _categorias[i];
                  final selected = _categoriaSelecionada == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _categoriaSelecionada = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.c500 : Colors.white,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color:
                              selected ? AppColors.c500 : AppColors.neutral200,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppColors.neutral600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Builder(
                builder: (context) {
                  final anuncios = _anunciosFiltrados;

                  if (anuncios.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: AppColors.c300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nenhum anúncio ainda.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.neutral500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Publique o primeiro!',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.neutral400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.c500,
                    onRefresh: () async => setState(() {}),
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: anuncios.length,
                      itemBuilder: (context, i) =>
                          _AnuncioCard(anuncio: anuncios[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PublishStep1Page()),
          );
          _carregarAnuncios();
        },
        backgroundColor: AppColors.c500,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Publicar',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _AnuncioCard extends StatelessWidget {
  final AnuncioEntity anuncio;
  const _AnuncioCard({required this.anuncio});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetalhesPage(anuncio: anuncio),
        ),
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
                  top: Radius.circular(16),
                ),
                child: anuncio.fotos.isEmpty
                    ? Container(
                        color: AppColors.c100,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.c400,
                          size: 36,
                        ),
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.c50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          anuncio.condicao,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.c700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          anuncio.faixaEtaria,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.neutral400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
