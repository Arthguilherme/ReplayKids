import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:replaykids/core/injector/injector.dart';
import 'package:replaykids/core/storage/storage_datasource.dart';
import 'package:replaykids/core/theme/app_colors.dart';
import 'package:replaykids/core/widgets/foto_widget.dart';
import 'package:replaykids/core/widgets/labeled_field.dart';
import 'package:replaykids/features/anuncio/data/models/anuncio_model.dart';
import 'package:replaykids/features/anuncio/domain/entities/anuncio_entity.dart';
import 'package:replaykids/features/anuncio/domain/repositories/anuncio_repository.dart';

class EditarAnuncioPage extends StatefulWidget {
  final AnuncioEntity anuncio;
  const EditarAnuncioPage({super.key, required this.anuncio});

  @override
  State<EditarAnuncioPage> createState() => _EditarAnuncioPageState();
}

class _EditarAnuncioPageState extends State<EditarAnuncioPage> {
  final _repository = injector.get<AnuncioRepository>();
  final _storage = injector.get<StorageDatasource>();

  late final _tituloController =
      TextEditingController(text: widget.anuncio.titulo);
  late final _descricaoController =
      TextEditingController(text: widget.anuncio.descricao);
  late final _precoController =
      TextEditingController(text: widget.anuncio.preco);

  late String _condicao = widget.anuncio.condicao;
  late String _categoria = widget.anuncio.categoria;
  late String _faixaEtaria = widget.anuncio.faixaEtaria;
  late bool _isVenda = widget.anuncio.isVenda;

  late List<dynamic> _fotos = List.from(widget.anuncio.fotos);

  bool _salvando = false;

  final _categorias = [
    'Brinquedos',
    'Roupas',
    'Carrinhos',
    'Móveis',
    'Livros',
    'Calçados',
    'Acessórios',
    'Outros',
  ];

  final _faixas = [
    '0-6m',
    '6-12m',
    '1-2 anos',
    '2-4 anos',
    '4-6 anos',
    '6+ anos',
  ];

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
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
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.c600),
              title: const Text('Escolher da galeria'),
              onTap: () async {
                Navigator.pop(context);
                await _adicionarFoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.camera_alt_outlined, color: AppColors.c600),
              title: const Text('Tirar foto'),
              onTap: () async {
                Navigator.pop(context);
                await _adicionarFoto(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _adicionarFoto(ImageSource source) async {
    if (_fotos.length >= 3) return;
    final picker = ImagePicker();
    final foto = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1080,
    );
    if (foto != null) {
      setState(() => _fotos = [..._fotos, foto]);
    }
  }

  void _removerFoto(int index) {
    setState(() => _fotos = [..._fotos]..removeAt(index));
  }

  Future<void> _salvar() async {
    if (_salvando) return;
    setState(() => _salvando = true);

    try {
      final urlsFinais = <String>[];
      for (final foto in _fotos) {
        if (foto is String) {
          urlsFinais.add(foto);
        } else {
          final url = await _storage.uploadFoto(foto.path);
          urlsFinais.add(url);
        }
      }

      await _repository.atualizar(
        AnuncioModel(
          id: widget.anuncio.id,
          usuarioId: widget.anuncio.usuarioId,
          titulo: _tituloController.text.trim(),
          descricao: _descricaoController.text.trim(),
          condicao: _condicao,
          categoria: _categoria,
          faixaEtaria: _faixaEtaria,
          isVenda: _isVenda,
          preco: _precoController.text.trim(),
          fotos: urlsFinais,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anúncio atualizado com sucesso!'),
            backgroundColor: AppColors.c600,
          ),
        );
        Navigator.maybePop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.c50,
      appBar: AppBar(
        backgroundColor: AppColors.c50,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral700),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Editar anúncio',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral800,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _salvando ? null : _salvar,
            child: _salvando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.c500),
                  )
                : const Text(
                    'Salvar',
                    style: TextStyle(
                      color: AppColors.c600,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.neutral100),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).padding.bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Fotos',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral700)),
            const SizedBox(height: 10),
            Row(
              children: [
                ...List.generate(3, (i) {
                  final temFoto = i < _fotos.length;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 2 ? 8 : 0),
                      child: temFoto
                          ? _FotoPreviewEdit(
                              src: _fotos[i] is String
                                  ? _fotos[i] as String
                                  : _fotos[i].path,
                              isUrl: _fotos[i] is String,
                              onRemover: () => _removerFoto(i),
                            )
                          : _SlotVazio(
                              addable: i == _fotos.length,
                              onTap: i == _fotos.length
                                  ? _mostrarOpcoesFoto
                                  : null,
                            ),
                    ),
                  );
                }),
              ],
            ),
            Text(
              '${_fotos.length}/3 fotos',
              style: const TextStyle(fontSize: 11, color: AppColors.neutral400),
            ),
            const SizedBox(height: 20),
            LabeledField(
              label: 'Título',
              hint: 'Ex: Ursinho de pelúcia',
              controller: _tituloController,
            ),
            const SizedBox(height: 12),
            const Text('Descrição',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral700)),
            const SizedBox(height: 6),
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
                  borderSide:
                      const BorderSide(color: AppColors.c400, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Condição',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Novo', 'Semi-novo', 'Usado'].map((c) {
                final sel = _condicao == c;
                return GestureDetector(
                  onTap: () => setState(() => _condicao = c),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.c500 : Colors.white,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                          color: sel ? AppColors.c500 : AppColors.neutral200),
                    ),
                    child: Text(c,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : AppColors.neutral700,
                        )),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Categoria',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categorias.map((c) {
                final sel = _categoria == c;
                return GestureDetector(
                  onTap: () => setState(() => _categoria = c),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.c500 : Colors.white,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                          color: sel ? AppColors.c500 : AppColors.neutral200),
                    ),
                    child: Text(c,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : AppColors.neutral700,
                        )),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Faixa etária',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral700)),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.6,
              children: _faixas.map((f) {
                final sel = _faixaEtaria == f;
                return GestureDetector(
                  onTap: () => setState(() => _faixaEtaria = f),
                  child: Container(
                    decoration: BoxDecoration(
                      color: sel ? AppColors.c500 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: sel ? AppColors.c500 : AppColors.neutral200),
                    ),
                    alignment: Alignment.center,
                    child: Text(f,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : AppColors.neutral700,
                        )),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Tipo de oferta',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral700)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isVenda = true),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isVenda ? AppColors.c500 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: _isVenda
                                ? AppColors.c500
                                : AppColors.neutral200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.local_offer_outlined,
                              color: _isVenda ? Colors.white : AppColors.c700,
                              size: 18),
                          const SizedBox(height: 6),
                          Text('Venda',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _isVenda
                                      ? Colors.white
                                      : AppColors.neutral800)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isVenda = false),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: !_isVenda ? AppColors.c500 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: !_isVenda
                                ? AppColors.c500
                                : AppColors.neutral200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.favorite_border,
                              color: !_isVenda ? Colors.white : AppColors.c700,
                              size: 18),
                          const SizedBox(height: 6),
                          Text('Doação',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: !_isVenda
                                      ? Colors.white
                                      : AppColors.neutral800)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isVenda) ...[
              LabeledField(
                label: 'Preço',
                hint: '0,00',
                controller: _precoController,
                keyboard: TextInputType.number,
                icon: Icons.attach_money_rounded,
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _FotoPreviewEdit extends StatelessWidget {
  final String src;
  final bool isUrl;
  final VoidCallback onRemover;
  const _FotoPreviewEdit(
      {required this.src, required this.isUrl, required this.onRemover});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: FotoWidget(src: src),
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
                    color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotVazio extends StatelessWidget {
  final bool addable;
  final VoidCallback? onTap;
  const _SlotVazio({this.addable = false, this.onTap});

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
                    Text('Adicionar',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.c600)),
                  ],
                )
              : const Icon(Icons.image_outlined, color: AppColors.neutral300),
        ),
      ),
    );
  }
}
