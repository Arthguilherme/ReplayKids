import 'package:image_picker/image_picker.dart';
import 'package:replaykids/features/anuncio/domain/entities/anuncio_entity.dart';
import 'package:replaykids/features/anuncio/domain/repositories/anuncio_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:replaykids/core/storage/storage_datasource.dart';

class PublishController {
  final AnuncioRepository repository;
  final StorageDatasource storageDatasource;

  PublishController({
    required this.repository,
    required this.storageDatasource,
  });

  String titulo = '';
  String descricao = '';
  String condicao = 'Novo';
  List<XFile> fotos = [];

  String categoria = 'Brinquedos';
  String faixaEtaria = '1-2 anos';
  bool isVenda = true;
  String preco = '100,00';

  Future<void> adicionarFoto(ImageSource source) async {
    if (fotos.length >= 4) return;

    final picker = ImagePicker();
    final foto = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1000,
    );

    if (foto != null) {
      fotos = [...fotos, foto];
    }
  }

  void removerFoto(int index) {
    fotos = [...fotos]..removeAt(index);
  }

  Future<void> publicar() async {
    final urlsFotos = <String>[];
    for (final foto in fotos) {
      try {
        final url = await storageDatasource.uploadFoto(foto.path);
        urlsFotos.add(url);
        debugPrint('Foto enviada: $url');
      } catch (e) {
        debugPrint('Erro ao enviar foto: $e');
      }
    }

    await repository.publicar(
      AnuncioEntity(
        id: 0,
        titulo: titulo.isEmpty ? 'Sem título' : titulo,
        descricao: descricao.isEmpty ? 'Sem descrição' : descricao,
        condicao: condicao,
        categoria: categoria,
        faixaEtaria: faixaEtaria,
        isVenda: isVenda,
        preco: preco,
        fotos: urlsFotos,
      ),
    );
    resetar();
  }

  void resetar() {
    titulo = '';
    descricao = '';
    condicao = 'Novo';
    fotos = [];
    categoria = 'Brinquedos';
    faixaEtaria = '1-2 anos';
    isVenda = true;
    preco = '100,00';
  }
}
