import 'dart:io';
import 'package:flutter/material.dart';
import 'package:replaykids/core/injector/injector.dart';
import 'package:replaykids/core/theme/app_colors.dart';
import 'package:replaykids/features/anuncio/domain/entities/anuncio_entity.dart';
import 'package:replaykids/features/anuncio/domain/repositories/anuncio_repository.dart';
import 'package:replaykids/features/favoritos/data/datasources/favoritos_datasource.dart';
import 'package:replaykids/features/produtos/presentation/pages/detalhes_page.dart';

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  final _favoritosDatasource = injector.get<FavoritosDatasource>();
  final _anuncioRepository = injector.get<AnuncioRepository>();
  List<AnuncioEntity> _favoritos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final ids = await _favoritosDatasource.listarIds();
      final todos = await _anuncioRepository.listar();
      setState(() {
        _favoritos = todos.where((a) => ids.contains(a.id)).toList();
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text(
                'Favoritos',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.c900,
                ),
              ),
            ),

            Expanded(
              child: _carregando
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.c500),
                    )
                  : _favoritos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.favorite_border_rounded,
                                  size: 64, color: AppColors.c300),
                              SizedBox(height: 16),
                              Text(
                                'Nenhum favorito ainda.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.neutral500,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Toque no ♡ para salvar anúncios.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.neutral400,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.c500,
                          onRefresh: _carregar,
                          child: GridView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                            itemCount: _favoritos.length,
                            itemBuilder: (context, i) => _FavoritoCard(
                              anuncio: _favoritos[i],
                              onVoltar: _carregar,
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritoCard extends StatelessWidget {
  final AnuncioEntity anuncio;
  final VoidCallback onVoltar;
  const _FavoritoCard({required this.anuncio, required this.onVoltar});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetalhesPage(anuncio: anuncio)),
      ).then((_) => onVoltar()),
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