import 'dart:io';
import 'package:flutter/material.dart';
import 'package:replaykids/core/theme/app_colors.dart';
import 'package:replaykids/features/anuncio/domain/entities/anuncio_entity.dart';

class DetalhesPage extends StatefulWidget {
  final AnuncioEntity anuncio;
  const DetalhesPage({super.key, required this.anuncio});

  @override
  State<DetalhesPage> createState() => _DetalhesPageState();
}

class _DetalhesPageState extends State<DetalhesPage> {
  int _fotoAtual = 0;
  bool _favoritado = false;

  @override
  Widget build(BuildContext context) {
    final anuncio = widget.anuncio;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          
          CustomScrollView(
            slivers: [
              
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 320,
                  child: Stack(
                    children: [
                      
                      anuncio.fotos.isEmpty
                          ? Container(
                              color: AppColors.c100,
                              alignment: Alignment.center,
                              child: const Icon(Icons.image_outlined,
                                  size: 64, color: AppColors.c300),
                            )
                          : PageView.builder(
                              itemCount: anuncio.fotos.length,
                              onPageChanged: (i) =>
                                  setState(() => _fotoAtual = i),
                              itemBuilder: (_, i) => Image.file(
                                File(anuncio.fotos[i]),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),

                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 100,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black38, Colors.transparent],
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        top: 48,
                        left: 16,
                        child: _CircleButton(
                          icon: Icons.arrow_back,
                          onTap: () => Navigator.maybePop(context),
                        ),
                      ),

                      Positioned(
                        top: 48,
                        right: 16,
                        child: _CircleButton(
                          icon: Icons.flag_outlined,
                          onTap: () {},
                        ),
                      ),

                      if (anuncio.fotos.length > 1)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              anuncio.fotos.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                width: _fotoAtual == i ? 16 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _fotoAtual == i
                                      ? Colors.white
                                      : Colors.white54,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              anuncio.titulo,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.c100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              anuncio.condicao.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.c800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Text(
                        anuncio.isVenda ? 'R\$ ${anuncio.preco}' : 'Doação',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.c600,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.neutral500),
                          const SizedBox(width: 4),
                          Text(
                            'Litoral do PR',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.neutral500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('•',
                              style:
                                  TextStyle(color: AppColors.neutral400)),
                          const SizedBox(width: 8),
                          const Icon(Icons.child_care_outlined,
                              size: 14, color: AppColors.neutral500),
                          const SizedBox(width: 4),
                          Text(
                            'Tam. ${anuncio.faixaEtaria}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      const Divider(color: AppColors.neutral100),
                      const SizedBox(height: 16),

                      const Text(
                        'Descrição',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        anuncio.descricao,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.neutral600,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Divider(color: AppColors.neutral100),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: AppColors.c200,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.person_outline,
                                color: AppColors.c700, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Vendedor',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.neutral800,
                                ),
                              ),
                              Row(
                                children: const [
                                  Icon(Icons.star_rounded,
                                      size: 14, color: Colors.amber),
                                  SizedBox(width: 4),
                                  Text(
                                    '4.9 • Membro desde 2025',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.neutral500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.neutral100),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text(
                        'Tenho interesse',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.c500,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  GestureDetector(
                    onTap: () => setState(() => _favoritado = !_favoritado),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.neutral200),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        _favoritado
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: _favoritado ? Colors.red : AppColors.neutral400,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: AppColors.neutral700),
      ),
    );
  }
}