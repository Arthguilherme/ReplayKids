import 'package:flutter/material.dart';
import 'package:replaykids/core/injector/injector.dart';
import 'package:replaykids/core/theme/app_colors.dart';
import 'package:replaykids/core/widgets/foto_widget.dart';
import 'package:replaykids/features/anuncio/domain/entities/anuncio_entity.dart';
import 'package:replaykids/features/anuncio/domain/repositories/anuncio_repository.dart';
import 'package:replaykids/features/anuncio/presentation/pages/publish_step1_page.dart';
import 'package:replaykids/features/chat/presentation/pages/chat_list_page.dart';
import 'package:replaykids/features/favoritos/presentation/pages/favoritos_page.dart';
import 'package:replaykids/features/perfil/presentation/pages/perfil_page.dart';
import 'package:replaykids/features/produtos/presentation/pages/detalhes_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _abaAtual = 0;
  final _feedKey = GlobalKey<_FeedViewState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        _FeedView(key: _feedKey),
        const FavoritosPage(),
        const ChatListPage(),
        const PerfilPage(),
      ][_abaAtual],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.neutral100)),
        ),
        child: BottomNavigationBar(
          currentIndex: _abaAtual < 2 ? _abaAtual : _abaAtual + 1,
          onTap: (i) {
            if (i == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PublishStep1Page()),
              ).then((_) {
                _feedKey.currentState?.recarregar();
              });
              return;
            }
            final novaAba = i < 2 ? i : i - 1;
            setState(() => _abaAtual = novaAba);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.c600,
          unselectedItemColor: AppColors.neutral400,
          selectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Início',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_rounded),
              activeIcon: Icon(Icons.favorite_rounded),
              label: 'Favoritos',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.c500,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 26),
              ),
              label: '',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              activeIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Chat',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedView extends StatefulWidget {
  const _FeedView({super.key});

  @override
  State<_FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<_FeedView> {
  final _repository = injector.get<AnuncioRepository>();
  String _categoriaSelecionada = 'Todos';
  String _textoBusca = '';
  late final _buscaController = TextEditingController();
  List<AnuncioEntity> _anuncios = [];


  final _categorias = [
    'Todos',
    'Brinquedos',
    'Roupas',
    'Carrinhos',
    'Móveis',
    'Livros',
    'Calçados',
    'Acessórios',
    'Outros',
  ];

  String? _municipioSelecionado;

  final _municipios = [
    'Todos',
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
    _carregarAnuncios();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarAnuncios() async {
    final anuncios = await _repository.listar();
    setState(() => _anuncios = anuncios);
  }

  Future<void> recarregar() => _carregarAnuncios();

  List<AnuncioEntity> get _anunciosFiltrados {
    var lista = _anuncios;

    if (_categoriaSelecionada != 'Todos') {
      lista = lista
        .where((a) => a.categoria == _categoriaSelecionada)
        .toList();
    }

    if (_municipioSelecionado != null && _municipioSelecionado != 'Todos') {
      lista = lista
        .where((a) => a.cidadeVendedor == _municipioSelecionado)
        .toList();
  }

    if (_textoBusca.isNotEmpty) {

      lista = lista
          .where((a) =>
              a.titulo.toLowerCase().contains(_textoBusca.toLowerCase()) ||
              a.descricao.toLowerCase().contains(_textoBusca.toLowerCase()))
          .toList();
    }

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'ReplayKids',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.c900,
                      ),
                    ),
                    Text(
                      'Litoral do Paraná',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.c700,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: TextField(
              controller: _buscaController,
              onChanged: (v) => setState(() => _textoBusca = v),
              decoration: InputDecoration(
                hintText: 'Buscar anúncios...',
                hintStyle:
                    const TextStyle(color: AppColors.neutral400, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.neutral400, size: 20),
                suffixIcon: _textoBusca.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.neutral400, size: 20),
                        onPressed: () {
                          _buscaController.clear();
                          setState(() => _textoBusca = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: DropdownButtonFormField<String>(
              value: _municipioSelecionado ?? 'Todos',
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_on_outlined,
                    color: AppColors.neutral400, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              items: _municipios
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(m,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.neutral700)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _municipioSelecionado = v),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categorias.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = _categorias[i];
                final selected = _categoriaSelecionada == cat;
                return GestureDetector(
                  onTap: () => setState(() => _categoriaSelecionada = cat),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.c500 : Colors.white,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: selected ? AppColors.c500 : AppColors.neutral200,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.neutral600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: Builder(
              builder: (context) {
                final anuncios = _anunciosFiltrados;

                if (anuncios.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _textoBusca.isNotEmpty
                              ? Icons.search_off_rounded
                              : Icons.inbox_outlined,
                          size: 64,
                          color: AppColors.c300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _textoBusca.isNotEmpty
                              ? 'Nenhum resultado para "$_textoBusca"'
                              : 'Nenhum anúncio ainda.',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _textoBusca.isNotEmpty
                              ? 'Tente buscar por outro termo'
                              : 'Toque em + para publicar!',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.c500,
                  onRefresh: _carregarAnuncios,
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: anuncios.length,
                    itemBuilder: (context, i) =>
                        _AnuncioCard(anuncio: anuncios[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AnuncioCard extends StatelessWidget {
  final AnuncioEntity anuncio;
  const _AnuncioCard({required this.anuncio});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetalhesPage(anuncio: anuncio),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neutral100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: anuncio.fotos.isEmpty
                    ? Container(
                        color: AppColors.c100,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_outlined,
                            color: AppColors.c400, size: 36),
                      )
                    : FotoWidget(src: anuncio.fotos.first),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anuncio.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.c50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          anuncio.condicao,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.c700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          anuncio.faixaEtaria,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.neutral400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    anuncio.isVenda ? 'R\$ ${anuncio.preco}' : 'Doação',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.c700,
                    ),
                  ),
                  if (anuncio.nomeVendedor != null)
                    Padding(
                      child:Row(
                      children: [
                        if (anuncio.tipoVendedor == 'bazar')
                          Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.c500,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Text(
                              'BAZAR',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            anuncio.nomeVendedor!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.neutral500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
