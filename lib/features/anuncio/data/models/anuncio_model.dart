import '../../domain/entities/anuncio_entity.dart';

class AnuncioModel extends AnuncioEntity {
  AnuncioModel({
    required super.id,
    super.usuarioId,
    super.nomeVendedor,
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
  
  String? nomeVendedor;
  final perfis = map['perfis'];
  if (perfis is Map) {
    nomeVendedor = perfis['nome'] as String?;
  } else if (perfis is List && perfis.isNotEmpty) {
      nomeVendedor = perfis.first['nome'] as String?;
  }
 
 
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
    //nomeVendedor: map['perfis'] != null ? map['perfis']['nome'] as String? : null,
    
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
      'fotos': fotos,
      //'fotos': jsonEncode(fotos),
    };
  }
}