import 'dart:convert';
import 'dart:io' show File, HttpException, stdout;
import 'package:http/http.dart' as http;
import 'package:tinygram/src/tinygram_chat.dart';

/// Represents a Telegram bot token.
typedef BotToken = String;

/// Interface for sending messages and files via Telegram Bot API.
abstract interface class TinygramBot {
  /// Sends a message to the Telegram chat.
  Future<void> sendMessage(
    String message, {
    String? parseMode,
    bool isJson = false,
  });

  /// Sends a file to the Telegram chat.
  Future<void> sendFile(File file);

  /// Fetches bot updates (e.g. to discover chat/channel IDs).
  Future<void> getUpdates({int? limit});
}

/// A base class that holds shared configuration for a Telegram bot.
base class BotBase {
  /// Creates a new instance of [TelegramBotBase].
  const BotBase({required this.token, required this.chatID});

  /// The Telegram bot token.
  final BotToken token;

  /// The chat ID where messages will be sent.
  final ChatID chatID;

  static const _baseUrl = 'https://api.telegram.org';

  /// Builds the URL for the Telegram Bot API method.
  Uri buildUrl(String method, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('$_baseUrl/bot$token/$method');
    return query != null ? uri.replace(queryParameters: query) : uri;
  }

  /// Formats a JSON string for better readability in Markdown.
  /// Escapes special characters to ensure proper rendering in Markdown.
  /// Returns a Markdown-formatted string with JSON content.
  String formatJson(String jsonStr) {
    final jsonObj = json.decode(jsonStr);
    final formatted = const JsonEncoder.withIndent('  ').convert(jsonObj);
    return '```json\n${_escapeMarkdown(formatted)}\n```';
  }

  /// Escapes special characters in a Markdown string.
  String _escapeMarkdown(String text) => text
      .replaceAll('_', r'\_')
      .replaceAll('*', r'\*')
      .replaceAll('[', r'\[')
      .replaceAll(']', r'\]')
      .replaceAll('(', r'\(')
      .replaceAll(')', r'\)')
      .replaceAll('~', r'\~')
      .replaceAll('`', r'\`')
      .replaceAll('>', r'\>')
      .replaceAll('#', r'\#')
      .replaceAll('+', r'\+')
      .replaceAll('-', r'\-')
      .replaceAll('=', r'\=')
      .replaceAll('|', r'\|')
      .replaceAll('{', r'\{')
      .replaceAll('}', r'\}')
      .replaceAll('.', r'\.')
      .replaceAll('!', r'\!');
}

final class TinygramBotImpl extends BotBase implements TinygramBot {
  /// Creates a new instance of [TinygramBotImpl].
  TinygramBotImpl({required super.token, required super.chatID});

  @override
  Future<void> sendMessage(
    String message, {
    String? parseMode,
    bool isJson = false,
  }) async {
    // Implementation for sending a message to the chat.
  }

   @override
  Future<void> sendFile(File file) async {
    if (!file.existsSync()) throw ArgumentError('File does not exist: ${file.path}');

    final mimeType = lookupMimeType(file.path);
    final request = http.MultipartRequest('POST', buildUrl('sendDocument'))
      ..fields['chat_id'] = chatID
      ..files.add(await http.MultipartFile.fromPath(
        'document',
        file.path,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      ));

    final response = await request.send();
    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw HttpException('Failed to send file: ${response.statusCode}\n$body');
    }
  }

  @override
  Future<void> getUpdates({int? limit}) async {
    final url = buildUrl('getUpdates', {'limit': limit?.toString()});
    stdout.writeln('Fetching updates from $url...');
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw HttpException(
        'Failed to fetch updates: ${res.statusCode}\n${res.body}',
      );
    }
    stdout.writeln(res.body);
  }
}
