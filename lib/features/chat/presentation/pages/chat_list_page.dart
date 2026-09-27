import 'package:flutter/material.dart';
import 'package:replaykids/core/injector/injector.dart';
import 'package:replaykids/core/theme/app_colors.dart';
import 'package:replaykids/features/chat/datasources/chat_datasource.dart';
import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final _datasource = injector.get<ChatDatasource>();
  List<Map<String, dynamic>> _conversas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    try {
      final conversas = await _datasource.listarConversas();
      setState(() {
        _conversas = conversas;
        _carregando = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar conversas: $e');
      setState(() => _carregando = false);
    }
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
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
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
                              final mensagens =
                                  conversa['mensagens'] as List? ?? [];
                              final ultimaMensagem = mensagens.isNotEmpty
                                  ? mensagens.last['texto'] as String
                                  : 'Nenhuma mensagem ainda';

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: AppColors.c100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.inventory_2_outlined,
                                    color: AppColors.c500,
                                  ),
                                ),
                                title: Text(
                                  anuncio?['titulo'] ?? 'Anúncio',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.neutral800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  ultimaMensagem,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.neutral500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(
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
                                ).then((_) => _carregar()),
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