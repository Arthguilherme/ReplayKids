import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:replaykids/core/injector/injector.dart';
import 'package:replaykids/core/theme/app_colors.dart';
import 'package:replaykids/core/widgets/foto_widget.dart';
import 'package:replaykids/features/chat/datasources/chat_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:replaykids/core/utils/profanity_filter.dart';
import '../notifications/nao_lidas_service.dart';

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
  bool _mostrarEmojis = false;
  bool _enviandoImagem = false;

  final _emojis = [
    '😀','😂','🥰','😍','🤩','😎','🥳','😊',
    '👍','👏','🙌','❤️','🔥','✨','🎉','💯',
    '😅','🤔','😮','😢','😡','🥺','😴','🤗',
    '👋','🙏','💪','🤝','✌️','👌','🫶','💬',
  ];

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
    _marcarLidas();
  }

  void _escutarMensagens() {
    _canal = _datasource.escutarMensagens(
      conversaId: widget.conversaId,
      onNovaMensagem: (mensagem) {
        setState(() => _mensagens.add(mensagem));
        _scrollParaBaixo();
        if (mensagem['remetente_id'] != _usuarioAtual?.id) {
          _marcarLidas(); 
  }
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

  Future<void> _marcarLidas() async {
    await _datasource.marcarComoLidas(widget.conversaId);
    injector.get<NaoLidasService>().atualizar();
  }

  Future<void> _enviarMensagem() async {
    final texto = _textoController.text.trim();
    if (texto.isEmpty) return;

    if (ProfanityFilter.contemPalavrao(texto)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sua mensagem contém conteúdo inadequado e não pode ser enviada.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    _textoController.clear();
    setState(() => _mostrarEmojis = false);
    await _datasource.enviarMensagem(
      conversaId: widget.conversaId,
      texto: texto,
    );
  }

  Future<void> _enviarImagem() async {
    final picker = ImagePicker();
    final foto = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1080,
    );
    if (foto == null) return;

    setState(() => _enviandoImagem = true);
    try {
      await _datasource.enviarImagem(
        conversaId: widget.conversaId,
        caminhoLocal: foto.path,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao enviar imagem')),
        );
      }
    } finally {
      setState(() => _enviandoImagem = false);
    }
  }

  void _inserirEmoji(String emoji) {
    final pos = _textoController.selection.baseOffset;
    final texto = _textoController.text;
    final novoTexto = pos < 0
        ? texto + emoji
        : texto.substring(0, pos) + emoji + texto.substring(pos);
    _textoController.value = TextEditingValue(
      text: novoTexto,
      selection: TextSelection.collapsed(
          offset: (pos < 0 ? texto.length : pos) + emoji.length),
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
                      final tipo = mensagem['tipo'] as String? ?? 'texto';
                      final anexoUrl = mensagem['anexo_url'] as String?;

                      return _BolhaMensagem(
                        texto: mensagem['texto'] as String,
                        ehMeu: ehMeu,
                        horario: mensagem['created_at'] as String,
                        tipo: tipo,
                        anexoUrl: anexoUrl,
                      );
                    },
                  ),
          ),

          if (_mostrarEmojis)
            SizedBox(
              height: 280,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  _inserirEmoji(emoji.emoji);
                },
                config: Config(
                  height: 280,
                  checkPlatformCompatibility: true,
                  emojiViewConfig: EmojiViewConfig(
                    emojiSizeMax: 28 * (foundation.defaultTargetPlatform == TargetPlatform.iOS ? 1.20 : 1.0),
                    backgroundColor: Colors.white,
                  ),
                  categoryViewConfig: const CategoryViewConfig(
                    initCategory: Category.SMILEYS,
                    backgroundColor: Colors.white,
                    indicatorColor: AppColors.c500,
                    iconColorSelected: AppColors.c500,
                    iconColor: AppColors.neutral400,
                  ),
                  bottomActionBarConfig: const BottomActionBarConfig(
                    backgroundColor: Colors.white,
                    buttonColor: Colors.white,
                    buttonIconColor: AppColors.neutral500,
                  ),
                  searchViewConfig: const SearchViewConfig(
                    backgroundColor: Colors.white,
                    buttonIconColor: AppColors.neutral500,
                  ),
                ),
              ),
            ),

          Container(
            padding: EdgeInsets.fromLTRB(
              12, 8, 12,
              MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.neutral100)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _mostrarEmojis = !_mostrarEmojis),
                  child: Icon(
                    _mostrarEmojis
                        ? Icons.keyboard_rounded
                        : Icons.emoji_emotions_outlined,
                    color: _mostrarEmojis
                        ? AppColors.c500
                        : AppColors.neutral400,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 8),

                GestureDetector(
                  onTap: _enviandoImagem ? null : _enviarImagem,
                  child: _enviandoImagem
                      ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.c500),
                        )
                      : const Icon(Icons.attach_file_rounded,
                          color: AppColors.neutral400, size: 24),
                ),
                const SizedBox(width: 8),

                Expanded(
                  child: TextField(
                    controller: _textoController,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onTap: () => setState(() => _mostrarEmojis = false),
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
                    width: 44, height: 44,
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
  final String tipo;
  final String? anexoUrl;

  const _BolhaMensagem({
    required this.texto,
    required this.ehMeu,
    required this.horario,
    required this.tipo,
    this.anexoUrl,
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
        child: tipo == 'imagem' && anexoUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(ehMeu ? 18 : 4),
                  bottomRight: Radius.circular(ehMeu ? 4 : 18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FotoWidget(src: anexoUrl!),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
                      child: Text(
                        _formatarHorario(horario),
                        style: TextStyle(
                          fontSize: 10,
                          color: ehMeu ? Colors.white70 : AppColors.neutral400,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                child: Column(
                  crossAxisAlignment: ehMeu
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
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
                        color: ehMeu
                            ? Colors.white70
                            : AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}