import 'package:flutter/material.dart';
import 'package:replaykids/core/injector/injector.dart';
import 'package:replaykids/core/theme/app_colors.dart';
import 'package:replaykids/features/chat/datasources/chat_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatPage extends StatefulWidget {
  final int conversaId;
  final String titulo;

  const ChatPage({
    super.key,
    required this.conversaId,
    required this.titulo,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _datasource = injector.get<ChatDatasource>();
  final _textoController = TextEditingController();
  final _scrollController = ScrollController();
  final _usuarioAtual = Supabase.instance.client.auth.currentUser;

  List<Map<String, dynamic>> _mensagens = [];
  RealtimeChannel? _canal;

  @override
  void initState() {
    super.initState();
    _carregarMensagens();
    _escutarMensagens();
  }

  @override
  void dispose() {
    _textoController.dispose();
    _scrollController.dispose();
    _canal?.unsubscribe();
    super.dispose();
  }

  Future<void> _carregarMensagens() async {
    final mensagens = await _datasource.listarMensagens(widget.conversaId);
    setState(() => _mensagens = mensagens);
    _scrollParaBaixo();
  }

  void _escutarMensagens() {
    _canal = _datasource.escutarMensagens(
      conversaId: widget.conversaId,
      onNovaMensagem: (mensagem) {
        setState(() => _mensagens.add(mensagem));
        _scrollParaBaixo();
      },
    );
  }

  void _scrollParaBaixo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _enviarMensagem() async {
    final texto = _textoController.text.trim();
    if (texto.isEmpty) return;

    _textoController.clear();

    await _datasource.enviarMensagem(
      conversaId: widget.conversaId,
      texto: texto,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.c50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral700),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          widget.titulo,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral800,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.neutral100),
        ),
      ),
      body: Column(
        children: [
          // Lista de mensagens
          Expanded(
            child: _mensagens.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma mensagem ainda.\nDiga olá! 👋',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.neutral400,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: _mensagens.length,
                    itemBuilder: (context, i) {
                      final mensagem = _mensagens[i];
                      final ehMeu =
                          mensagem['remetente_id'] == _usuarioAtual?.id;
                      return _BolhaMensagem(
                        texto: mensagem['texto'] as String,
                        ehMeu: ehMeu,
                        horario: mensagem['created_at'] as String,
                      );
                    },
                  ),
          ),

          // Campo de texto
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.neutral100)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textoController,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Digite uma mensagem...',
                      hintStyle: const TextStyle(
                          color: AppColors.neutral400, fontSize: 14),
                      filled: true,
                      fillColor: AppColors.neutral100,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _enviarMensagem,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.c500,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BolhaMensagem extends StatelessWidget {
  final String texto;
  final bool ehMeu;
  final String horario;

  const _BolhaMensagem({
    required this.texto,
    required this.ehMeu,
    required this.horario,
  });

  String _formatarHorario(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: ehMeu ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: ehMeu ? AppColors.c500 : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(ehMeu ? 18 : 4),
            bottomRight: Radius.circular(ehMeu ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              ehMeu ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              texto,
              style: TextStyle(
                fontSize: 14,
                color: ehMeu ? Colors.white : AppColors.neutral800,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatarHorario(horario),
              style: TextStyle(
                fontSize: 10,
                color: ehMeu ? Colors.white70 : AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}