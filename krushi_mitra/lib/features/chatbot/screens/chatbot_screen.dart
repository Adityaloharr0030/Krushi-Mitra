import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/chatbot_provider.dart';

import '../../../shared/widgets/custom_app_bar.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
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

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    
    // Auto scroll when new message arrives
    ref.listen(chatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Krushi Assistant',
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white),
            onPressed: () => ref.read(chatProvider.notifier).clearChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: chatState.messages.length + (chatState.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chatState.messages.length) {
                  return _buildTypingIndicator();
                }
                final msg = chatState.messages[index];
                return msg.isUser 
                  ? _buildUserMessage(msg.text, 'Just now')
                  : _buildAIMessage(msg.text, 'Now');
              },
            ),
          ),
          _buildInputArea(chatState.isTyping),
        ],
      ),
    );
  }

  Widget _buildAIMessage(String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: MarkdownBody(
              data: text,
              styleSheet: MarkdownStyleSheet(
                p: GoogleFonts.plusJakartaSans(
                  fontSize: 14, 
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
                strong: GoogleFonts.plusJakartaSans(
                  fontSize: 14, 
                  color: AppColors.primaryEmerald,
                  fontWeight: FontWeight.w800,
                ),
                listBullet: GoogleFonts.plusJakartaSans(
                  fontSize: 14, 
                  color: AppColors.primaryEmerald,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'Krushi AI Assistant • $time',
              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textHint, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
            decoration: BoxDecoration(
              gradient: AppTheme.celestialGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryEmerald.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              'You • $time',
              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textHint, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          ...List.generate(3, (i) => Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          )),
          const SizedBox(width: 8),
          Text('Krushi AI is thinking...', style: GoogleFonts.manrope(fontSize: 12, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isTyping) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  _buildSuggestionChip('🌾 Wheat disease diagnosis?', isTyping),
                  _buildSuggestionChip('📅 Crop calendar for Cotton', isTyping),
                  _buildSuggestionChip('💰 Latest Mandi prices', isTyping),
                  _buildSuggestionChip('🏛️ Subsidy schemes', isTyping),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _messageController,
                      enabled: !isTyping,
                      style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Ask anything about farming...',
                        border: InputBorder.none,
                        hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textHint, fontWeight: FontWeight.w500),
                      ),
                      onSubmitted: (val) => _handleSend(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: isTyping ? null : _handleSend,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: isTyping ? null : AppTheme.celestialGradient,
                    color: isTyping ? AppColors.outlineVariant : null,
                    shape: BoxShape.circle,
                    boxShadow: isTyping ? null : [
                      BoxShadow(
                        color: AppColors.primaryEmerald.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isTyping ? Icons.hourglass_top_rounded : Icons.send_rounded, 
                    color: Colors.white, 
                    size: 24
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleSend() {
    final text = _messageController.text;
    if (text.isEmpty) return;
    _messageController.clear();
    ref.read(chatProvider.notifier).sendMessage(text, 'en');
  }

  Widget _buildSuggestionChip(String label, bool isTyping) {
    return GestureDetector(
      onTap: isTyping ? null : () {
        _messageController.text = label;
        _handleSend();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryEmerald,
          ),
        ),
      ),
    );
  }
}
