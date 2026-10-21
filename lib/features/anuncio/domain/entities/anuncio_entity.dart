class AnuncioEntity {
  final int id;
  final String? usuarioId;
  final String titulo;
  final String descricao;
  final String condicao;
  final String categoria;
  final String faixaEtaria;
  final bool isVenda;
  final String preco;
  final List<String> fotos;
  final String? nomeVendedor;
  final String? cidadeVendedor;
  final String? tipoVendedor;


AnuncioEntity({
    required this.id,
    this.usuarioId,
    required this.titulo,
    required this.descricao,
    required this.condicao,
    required this.categoria,
    required this.faixaEtaria,
    required this.isVenda,
    required this.preco,
    this.nomeVendedor,
    this.cidadeVendedor,
    this.fotos = const [],
    this.tipoVendedor,
  });
}