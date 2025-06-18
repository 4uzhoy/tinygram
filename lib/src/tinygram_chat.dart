/// Unique identifier of a chat (private, group or channel).
typedef ChatID = String;

/// Base class for all chat types in Tinygram.
abstract class ChatBase {
  /// Creates a new instance of [ChatBase].
  const ChatBase(this.chatID);

  /// The unique identifier for the chat.
  final ChatID chatID;
}

/// Represents a chat in Tinygram (private chat, group, or channel).
final class TinygramChat extends ChatBase {
  /// Creates a new instance of [TinygramChat].
  const TinygramChat(super.chatID);
}
