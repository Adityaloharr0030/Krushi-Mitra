import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';
import 'smart_context_provider.dart';

class ChatMessage {
  final String role;
  final String text;

  ChatMessage({required this.role, required this.text});

  bool get isUser => role == 'user';
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isTyping;

  ChatState({this.messages = const [], this.isLoading = false, this.isTyping = false});

  ChatState copyWith({List<ChatMessage>? messages, bool? isLoading, bool? isTyping}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;
  ChatNotifier(this._ref) : super(ChatState());

  Future<void> sendMessage(String text) async {
    final context = _ref.read(ubiquitousContextProvider);
    state = state.copyWith(
      messages: [...state.messages, ChatMessage(role: 'user', text: text)],
      isTyping: true,
    );

    try {
      final history = state.messages.map((m) => {
        'role': m.role == 'user' ? 'user' : 'model',
        'content': m.text,
      }).toList();

      final response = await AIService().chat(history, text, context);

      state = state.copyWith(
        messages: [...state.messages, ChatMessage(role: 'bot', text: response)],
        isTyping: false,
      );
    } catch (e) {
      final errorStr = e.toString();
      String errorMsg = 'Sorry, I encountered an error. Please try again.';
      
      if (errorStr.contains('OFFLINE') || errorStr.contains('connection')) {
        errorMsg = '📡 **Connection Error**\n\nPlease check your internet and try again. I can only provide limited help while offline.';
      } else if (errorStr.contains('Quota') || errorStr.contains('exhausted')) {
        errorMsg = '⏳ **Service Busy**\n\nThe AI servers are currently at capacity. Please try again in a few minutes.';
      }

      state = state.copyWith(
        isTyping: false,
        messages: [...state.messages, ChatMessage(role: 'bot', text: errorMsg)],
      );
      debugPrint('Chat Error: $e');
    }
  }

  void clearChat() {
    state = ChatState();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});
