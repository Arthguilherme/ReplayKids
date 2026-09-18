import 'dart:convert';
import '../../domain/entities/anuncio_entity.dart';

class AnuncioModel extends AnuncioEntity {
  AnuncioModel({
    required super.id,
    super.usuarioId,
    required super.titulo,
    required super.descricao,
    required super.condicao,
    required super.categoria,
    required super.faixaEtaria,
    required super.isVenda,
    required super.preco,
    super.fotos = const [],
  });

 
factory AnuncioModel.fromMap(Map<String, dynamic> map) {
  return AnuncioModel(
    id: map['id'] as int,
    usuarioId: map['usuario_id'] as String?,
    titulo: map['titulo'] as String,
    descricao: map['descricao'] as String,
    condicao: map['condicao'] as String,
    categoria: map['categoria'] as String,
    faixaEtaria: map['faixa_etaria'] as String,
    isVenda: map['is_venda'] as bool,
    preco: map['preco'] as String,
    fotos: List<String>.from(map['fotos'] ?? []),
  );
}

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'condicao': condicao,
      'categoria': categoria,
      'faixa_etaria': faixaEtaria,
      'is_venda': isVenda ? 1 : 0,
      'preco': preco,
      'fotos': jsonEncode(fotos),
    };
  }
}