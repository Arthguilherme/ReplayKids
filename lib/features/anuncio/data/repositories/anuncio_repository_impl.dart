import 'package:replaykids/features/anuncio/data/datasources/anuncio_datasource.dart';
import 'package:replaykids/features/anuncio/data/models/anuncio_model.dart';
import 'package:replaykids/features/anuncio/domain/entities/anuncio_entity.dart';
import 'package:replaykids/features/anuncio/domain/repositories/anuncio_repository.dart';

class AnuncioRepositoryImpl implements AnuncioRepository {
  final AnuncioDatasource datasource;
  
  AnuncioRepositoryImpl({required this.datasource});
  
  @override
  Future<List<AnuncioEntity>> listar() async {
    return await datasource.listar();
  }

  @override
  Future <void> publicar(AnuncioEntity anuncio) async {
   final model = AnuncioModel(
        id: anuncio.id,
        titulo: anuncio.titulo,
        descricao: anuncio.descricao,
        condicao: anuncio.condicao,
        categoria: anuncio.categoria,
        faixaEtaria: anuncio.faixaEtaria,
        isVenda: anuncio.isVenda,
        preco: anuncio.preco,
        fotos: anuncio.fotos,
      );
      await datasource.publicar(model);
  }

  @override
  Future<void> deletar(int id) async {
    await datasource.deletar(id);
}
}