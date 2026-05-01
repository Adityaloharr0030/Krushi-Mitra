import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';

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
  ChatNotifier() : super(ChatState());

  Future<void> sendMessage(String text, String lang) async {
    state = state.copyWith(
      messages: [...state.messages, ChatMessage(role: 'user', text: text)],
      isTyping: true,
    );

    try {
      final history = state.messages.map((m) => {
        'role': m.role == 'user' ? 'user' : 'model',
        'content': m.text,
      }).toList();

      final response = await AIService().chat(history, text, lang);

      state = state.copyWith(
        messages: [...state.messages, ChatMessage(role: 'bot', text: response)],
        isTyping: false,
      );
    } catch (e) {
      state = state.copyWith(
        isTyping: false,
        messages: [...state.messages, ChatMessage(role: 'bot', text: 'Sorry, I encountered an error. Please try again.')],
      );
      debugPrint('Chat Error: $e');
    }
  }

  void clearChat() {
    state = ChatState();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
