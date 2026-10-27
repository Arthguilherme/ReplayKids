import '../../domain/entities/anuncio_entity.dart';

class AnuncioModel extends AnuncioEntity {
  AnuncioModel({
    required super.id,
    super.usuarioId,
    super.nomeVendedor,
    super.cidadeVendedor,
    super.tipoVendedor,
    super.fotos = const [],
    required super.titulo,
    required super.descricao,
    required super.condicao,
    required super.categoria,
    required super.faixaEtaria,
    required super.isVenda,
    required super.preco,

  });

factory AnuncioModel.fromMap(Map<String, dynamic> map) {
  
  String? nomeVendedor;
  String? cidadeVendedor;
  String? tipoVendedor;

  final perfis = map['perfis'];

  if (perfis is Map) {
    nomeVendedor = perfis['nome'] as String?;
    cidadeVendedor = perfis['cidade'] as String?;
    tipoVendedor = perfis['tipo'] as String?;
  } else if (perfis is List && perfis.isNotEmpty) {
      nomeVendedor = perfis.first['nome'] as String?;
      cidadeVendedor = perfis.first['cidade'] as String?;
      tipoVendedor = perfis.first['tipo'] as String?;
  }
 
 
  return AnuncioModel(
    id: map['id'] as int,
    usuarioId: map['usuario_id'] as String?,
    nomeVendedor: nomeVendedor,      
    cidadeVendedor: cidadeVendedor,
    tipoVendedor: tipoVendedor,
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
      'fotos': fotos,
    };
  }
}