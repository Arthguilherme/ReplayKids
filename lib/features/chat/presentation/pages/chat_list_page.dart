import 'package:flutter/material.dart';
import 'package:replaykids/core/injector/injector.dart';
import 'package:replaykids/core/notifications/nao_lidas_service.dart';
import 'package:replaykids/core/theme/app_colors.dart';
import 'package:replaykids/core/widgets/foto_widget.dart';
import 'package:replaykids/features/chat/datasources/chat_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final _datasource = injector.get<ChatDatasource>();
  final _naoLidas = injector.get<NaoLidasService>();
  final _meuId = Supabase.instance.client.auth.currentUser?.id;

  List<Map<String, dynamic>> _conversas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
    _naoLidas.total.addListener(_aoMudarNaoLidas);
  }

  @override
  void dispose() {
    _naoLidas.total.removeListener(_aoMudarNaoLidas);
    super.dispose();
  }

  void _aoMudarNaoLidas() => _carregar(silencioso: true);

  Future<void> _carregar({bool silencioso = false}) async {
    if (!silencioso) setState(() => _carregando = true);
    try {
      final conversas = await _datasource.listarConversas();
      conversas.sort((a, b) => _dataUltima(b).compareTo(_dataUltima(a)));
      if (!mounted) return;
      setState(() {
        _conversas = conversas;
        _carregando = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar conversas: $e');
      if (mounted) setState(() => _carregando = false);
    }
  }

  List<Map<String, dynamic>> _mensagensDe(Map<String, dynamic> conversa) {
    return ((conversa['mensagens'] as List?) ?? [])
        .cast<Map<String, dynamic>>();
  }

  Map<String, dynamic>? _ultimaMensagem(Map<String, dynamic> conversa) {
    final msgs = _mensagensDe(conversa);
    if (msgs.isEmpty) return null;
    return msgs.reduce((a, b) =>
        (a['created_at'] as String).compareTo(b['created_at'] as String) >= 0
            ? a
            : b);
  }

  String _dataUltima(Map<String, dynamic> conversa) {
    final ultima = _ultimaMensagem(conversa);
    return (ultima?['created_at'] ?? conversa['created_at'] ?? '') as String;
  }

  int _contarNaoLidas(Map<String, dynamic> conversa) {
    return _mensagensDe(conversa)
        .where((m) => m['lida'] == false && m['remetente_id'] != _meuId)
        .length;
  }

  String _previa(Map<String, dynamic>? ultima) {
    if (ultima == null) return 'Nenhuma mensagem ainda';
    final texto =
        ultima['tipo'] == 'imagem' ? '📷 Imagem' : (ultima['texto'] as String);
    return ultima['remetente_id'] == _meuId ? 'Você: $texto' : texto;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.c50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text(
                'Mensagens',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.c900,
                ),
              ),
            ),
            Expanded(
              child: _carregando
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.c500),
                    )
                  : _conversas.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded,
                                  size: 64, color: AppColors.c300),
                              SizedBox(height: 16),
                              Text(
                                'Nenhuma conversa ainda.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.neutral500,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Toque em "Tenho interesse" em um anúncio.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.neutral400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.c500,
                          onRefresh: _carregar,
                          child: ListView.separated(
                            itemCount: _conversas.length,
                            separatorBuilder: (_, __) => const Divider(
                              height: 1,
                              color: AppColors.neutral100,
                            ),
                            itemBuilder: (context, i) {
                              final conversa = _conversas[i];
                              final anuncio = conversa['anuncios'] as Map?;
                              final fotos = (anuncio?['fotos'] as List?) ?? [];
                              final naoLidas = _contarNaoLidas(conversa);
                              final temNova = naoLidas > 0;

                              return ListTile(
                                tileColor: temNova
                                    ? AppColors.c100.withOpacity(0.6)
                                    : null,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: fotos.isEmpty
                                        ? Container(
                                            color: AppColors.c100,
                                            child: const Icon(
                                              Icons.inventory_2_outlined,
                                              color: AppColors.c500,
                                            ),
                                          )
                                        : FotoWidget(src: fotos.first as String),
                                  ),
                                ),
                                title: Text(
                                  anuncio?['titulo'] ?? 'Anúncio',
                                  style: TextStyle(
                                    fontWeight: temNova
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.neutral800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  _previa(_ultimaMensagem(conversa)),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: temNova
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: temNova
                                        ? AppColors.neutral800
                                        : AppColors.neutral500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: temNova
                                    ? Container(
                                        constraints: const BoxConstraints(
                                            minWidth: 24),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.c500,
                                          borderRadius:
                                              BorderRadius.circular(99),
                                        ),
                                        child: Text(
                                          naoLidas > 99 ? '99+' : '$naoLidas',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.chevron_right_rounded,
                                        color: AppColors.neutral400,
                                      ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatPage(
                                      conversaId: conversa['id'] as int,
                                      titulo: anuncio?['titulo'] ?? 'Chat',
                                    ),
                                  ),
                                ).then((_) => _carregar(silencioso: true)),
                              );
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