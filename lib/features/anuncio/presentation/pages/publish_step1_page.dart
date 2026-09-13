import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:replaykids/core/injector/injector.dart';
import 'package:replaykids/core/theme/app_colors.dart';
import 'package:replaykids/core/widgets/labeled_field.dart';
import 'package:replaykids/features/anuncio/presentation/controllers/publish_controller.dart';
import 'package:replaykids/features/anuncio/presentation/widgets/publish_scaffold.dart';
import 'publish_step2_page.dart';

class PublishStep1Page extends StatefulWidget {
  const PublishStep1Page({super.key});

  @override
  State<PublishStep1Page> createState() => _PublishStep1PageState();
}

class _PublishStep1PageState extends State<PublishStep1Page> {
  final _controller = injector.get<PublishController>();
  late final _tituloController =
      TextEditingController(text: _controller.titulo);
  late final _descricaoController =
      TextEditingController(text: _controller.descricao);

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

    void _mostrarOpcoesFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.c600),
              title: const Text('Escolher da galeria'),
              onTap: () async {
                Navigator.pop(context);
                await _controller.adicionarFoto(ImageSource.gallery);
                setState(() {});
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.c600),
              title: const Text('Tirar foto'),
              onTap: () async {
                Navigator.pop(context);
                await _controller.adicionarFoto(ImageSource.camera);
                setState(() {});
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return buildPublishScaffold(
      context: context,
      step: '1/3',
      progress: 1 / 3,
      title: 'Publicar Anúncio',
      leading: Icons.close,
      primaryLabel: 'Próximo Passo',
      onPrimary: () {
        _controller.titulo = _tituloController.text;
        _controller.descricao = _descricaoController.text;

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PublishStep2Page()),
        );
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Fotos do item'),
          Row(
            children: [
               ...List.generate(3, (i) {
                final temFoto = i < _controller.fotos.length;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                    child: temFoto
                        ? _FotoPreview(
                            path: _controller.fotos[i].path,
                            onRemover: () {
                              _controller.removerFoto(i);
                              setState(() {});
                            },
                          )
                        : _PhotoSlot(
                            addable: i == _controller.fotos.length,
                            onTap: i == _controller.fotos.length
                                ? _mostrarOpcoesFoto
                                : null,
                          ),
                  ),
                );
              }),
            ],
          ),

          const SizedBox(height: 6),
          Text(
            '${_controller.fotos.length}/3 fotos adicionadas',
            style: const TextStyle( 
              fontSize: 11,
              color: AppColors.neutral400,
            ),
          ),
          const SizedBox(height: 18),

          const SectionLabel('Título'),
          LabeledField(
            label: '',
            hint: 'Ex: Ursinho de pelúcia',
            controller: _tituloController,
          ),
          const SizedBox(height: 12),

          const SectionLabel('Descrição'),
          TextField(
            controller: _descricaoController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Conte mais sobre o produto...',
              hintStyle:
                  const TextStyle(color: AppColors.neutral400, fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.neutral200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.c400, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 14),

          const SectionLabel('Condição'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Novo', 'Semi-novo', 'Usado'].map((c) {
              return SelectChip(
                c,
                selected: _controller.condicao == c,
                onTap: () => setState(() => _controller.condicao = c),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  final bool addable;
  final VoidCallback? onTap;
  const _PhotoSlot({this.addable = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.c50,
            borderRadius: BorderRadius.circular(14),
            border: addable
                ? Border.all(color: AppColors.c300, width: 1.5)
                : Border.all(color: AppColors.neutral200),
          ),
          alignment: Alignment.center,
          child: addable
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_camera_outlined, color: AppColors.c600),
                    SizedBox(height: 4),
                    Text(
                      'Adicionar',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.c600,
                      ),
                    ),
                  ],
                )
              : const Icon(Icons.image_outlined, color: AppColors.neutral300),
        ),
      ),
    );
  }
}

class _FotoPreview extends StatelessWidget {
  final String path;
  final VoidCallback onRemover;
  const _FotoPreview({required this.path, required this.onRemover});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemover,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close,
                    size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
