import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  void sendMessage(String text, String lang) {
    state = state.copyWith(
      messages: [...state.messages, ChatMessage(role: 'user', text: text)],
      isTyping: true,
    );
    // Mock response
    Future.delayed(const Duration(seconds: 1), () {
      state = state.copyWith(
        messages: [...state.messages, ChatMessage(role: 'bot', text: 'I am your Krushi Mitra assistant. How can I help with your farming needs?')],
        isTyping: false,
      );
    });
  }

  void clearChat() {
    state = ChatState();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
