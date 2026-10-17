import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:replaykids/core/injector/injector.dart';
import 'package:replaykids/core/theme/app_colors.dart';
import 'package:replaykids/core/widgets/foto_widget.dart';
import 'package:replaykids/core/widgets/labeled_field.dart';
import 'package:replaykids/features/perfil/data/datasources/perfil_datasource.dart';

class EditarPerfilPage extends StatefulWidget {
  final Map<String, dynamic> perfil;
  const EditarPerfilPage({super.key, required this.perfil});

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final _datasource = injector.get<PerfilDatasource>();

  late final _nomeController =
      TextEditingController(text: widget.perfil['nome'] as String? ?? '');
  late final _telefoneController =
      TextEditingController(text: widget.perfil['telefone'] as String? ?? '');

  late String _cidadeSelecionada =
      widget.perfil['cidade'] as String? ?? 'Matinhos, PR';

  String? _fotoAtualUrl = null;
  XFile? _novaFoto;
  bool _salvando = false;

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
  void initState() {
    super.initState();
    _fotoAtualUrl = widget.perfil['foto_url'] as String?;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
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
              width: 40, height: 4,
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
                await _selecionarFoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.c600),
              title: const Text('Tirar foto'),
              onTap: () async {
                Navigator.pop(context);
                await _selecionarFoto(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _selecionarFoto(ImageSource source) async {
    final picker = ImagePicker();
    final foto = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 512,
    );
    if (foto != null) {
      setState(() => _novaFoto = foto);
    }
  }

  Future<void> _salvar() async {
    if (_salvando) return;
    if (_nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome é obrigatório')),
      );
      return;
    }

    setState(() => _salvando = true);
    try {
      if (_novaFoto != null) {
        await _datasource.uploadFotoPerfil(_novaFoto!.path);
      }

      await _datasource.atualizarPerfil(
        nome: _nomeController.text.trim(),
        telefone: _telefoneController.text.trim(),
        cidade: _cidadeSelecionada,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
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
      if (mounted){
        setState(() => _salvando = false);
      }
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
          'Editar perfil',
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
                    width: 20, height: 20,
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _mostrarOpcoesFoto,
                child: Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        color: AppColors.c200,
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _novaFoto != null
                          ? Image.file(
                              File(_novaFoto!.path),
                              fit: BoxFit.cover,
                            )
                          : _fotoAtualUrl != null && _fotoAtualUrl!.isNotEmpty
                              ? FotoWidget(src: _fotoAtualUrl!)
                              : const Icon(
                                  Icons.person_rounded,
                                  size: 48,
                                  color: AppColors.c600,
                                ),
                        ),
                          
                    
                    
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 28),

            LabeledField(
              label: 'Nome completo',
              hint: 'Seu nome',
              icon: Icons.person_outline,
              controller: _nomeController,
            ),
            const SizedBox(height: 16),

            LabeledField(
              label: 'Telefone',
              hint: '(41) 99999-0000',
              icon: Icons.phone_outlined,
              controller: _telefoneController,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 6),
              child: Text(
                'Município',
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
                  icon: const Icon(Icons.expand_more,
                      color: AppColors.neutral400),
                  items: _cidades
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c,
                                style: const TextStyle(fontSize: 13)),
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
      ),
    );
  }
}