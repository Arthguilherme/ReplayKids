import '../entities/anuncio_entity.dart';

abstract class AnuncioRepository {
  Future<List<AnuncioEntity>> listar();
  Future<void> publicar(AnuncioEntity anuncio);
  Future<void> deletar(int id);
}