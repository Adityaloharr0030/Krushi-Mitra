import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final String? error;

  ChatState({
    this.messages = const [],
    this.isTyping = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      error: error ?? this.error,
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(ChatState(messages: [
    ChatMessage(
      text: 'Namaste! I am Krushi AI. How can I help you with your farming today?',
      isUser: false,
      timestamp: DateTime.now(),
    ),
  ]));

  Future<void> sendMessage(String text, String language) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isTyping: true,
      error: null,
    );

    try {
      // Prepare history for API
      final history = state.messages.map((m) => {
        'role': m.isUser ? 'user' : 'model',
        'content': m.text,
      }).toList();

      final response = await AIService().chat(history, text, language);
      
      final aiMessage = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isTyping: false,
      );
    } catch (e) {
      state = state.copyWith(
        isTyping: false,
        error: 'Failed to connect to Krushi AI: $e',
      );
    }
  }

  void clearChat() {
    state = ChatState(messages: [
      ChatMessage(
        text: 'Chat cleared. How can I help you now?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ]);
  }
}
