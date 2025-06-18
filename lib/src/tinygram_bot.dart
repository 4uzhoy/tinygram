// ignore_for_file: use_raw_strings

import 'dart:convert';
import 'dart:io' show File, HttpException, stdout;

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:mime/mime.dart';
import 'package:tinygram/src/tinygram_chat.dart';

/// Represents a Telegram bot token.
typedef BotToken = String;

/// Interface for sending messages and files via Telegram Bot API.
abstract interface class TinygramBot {
  /// Sends a message to the Telegram chat.
  /// [parseMode] can be used to specify the format of the message. it's optional.
  /// Use 'MarkdownV2' for Markdown formatting or 'HTML' for HTML formatting.
  ///
  /// Use format flags to control message formatting:
  ///
  /// If [formatMarkdown] is true, [parseMode] will be set to 'MarkdownV2'.
  /// *bold*, _italic_, [links](https://example.com), and other Markdown features will be applied.
  /// otherwise, the message will be sent as plain text. like "*bold*, _italic_, [links](https://example.com)",
  /// without any formatting.
  ///
  Future<void> sendMessage(
    Object message, {
    bool formatMarkdown = false,
    String? parseMode,
  });

  /// Sends a file to the Telegram chat.
  Future<void> sendFile(File file);

  /// Fetches bot updates (e.g. to discover chat/channel IDs).
  Future<void> getUpdates({int? limit});
}

/// A base class that holds shared configuration for a Telegram bot.
base class BotBase {
  /// Creates a new instance of [TelegramBotBase].
  const BotBase({required this.token, required this.chat, this.baseUrl});

  /// The Telegram bot token.
  final BotToken token;

  /// The chat where messages will be sent.
  final TinygramChat chat;

  /// The base URL for the Telegram Bot API.
  /// If not provided, it defaults to 'https://api.telegram.org'.
  final String? baseUrl;
  static const _baseUrl = 'https://api.telegram.org';

  /// Builds the URL for the Telegram Bot API method.
  Uri buildUrl(String method, [Map<String, dynamic>? query]) {
    final url = baseUrl ?? _baseUrl;
    final uri = Uri.parse('$url/bot$token/$method');
    return query != null ? uri.replace(queryParameters: query) : uri;
  }

  /// Formats a JSON string for better readability in Markdown.
  /// Escapes special characters to ensure proper rendering in Markdown.
  /// Returns a Markdown-formatted string with JSON content.
  String formatJson(Object json) {
    final formatted = const JsonEncoder.withIndent('  ').convert(json);
    return '```json\n$formatted\n```';
  }

  /// Escapes special characters in a Markdown string.
  String escapeMarkdownV2(String text) {
    const reserved = r'\[]()~`>#+-=|{}.!';
    final buffer = StringBuffer();
    for (final char in text.runes.map(String.fromCharCode)) {
      if (reserved.contains(char)) {
        buffer.write('\\$char');
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  /// Escapes Markdown V2 special characters in a string, while preserving
  /// certain formatting like bold, italic, links, and inline code.
  ///
  /// This Necessary because there is case when we should escape symbols
  /// for example 'Hi! *Tinygram*' is ok
  /// but 'Hi! *Tinygram!*' is not ok without escaping the exclamation mark.
  /// It uses a regular expression to match and preserve formatting,
  /// while escaping other special characters.
}

/// {@template tinygram_bot}
/// {@category Tinygram}
/// A simple Telegram bot implementation for sending messages and files.
/// It provides methods to send text messages, files, and fetch updates.
/// {@endtemplate}
final class TinygramBotImpl extends BotBase implements TinygramBot {
  /// Creates a new instance of [TinygramBotImpl].
  TinygramBotImpl({
    required super.token,
    required super.chat,
    super.baseUrl,
    this.isLogginEnabled = true,
  }) : assert(token.isNotEmpty, 'Token cannot be empty.');

  /// Whether logging is enabled for debugging purposes.
  /// If true, logs will be printed to the console.
  final bool isLogginEnabled;

  /// The chat ID where messages will be sent.
  String get chatID => chat.chatID;

  /// Logs messages to the console if logging is enabled.
  /// If [isProcessing] is true, it will append '...' to indicate processing.
  void log(Object message, {bool isProcessing = false}) {
    if (isLogginEnabled) {
      stdout.writeln('$message${isProcessing ? '...' : ''}');
    }
  }

  @override
  Future<void> sendMessage(
    Object message, {

    bool formatMarkdown = false,

    String? parseMode,
  }) async {
    log('Preparing to send message', isProcessing: true);
    if (chatID.isEmpty) throw StateError('Missing chat ID.');

    var formattedMessage = message;
    var selectedParseMode = parseMode;
    final url = buildUrl('sendMessage');

    if (message is String && message.isEmpty) {
      throw ArgumentError('Message cannot be empty.');
    }
    if (message is int ||
        message is double ||
        message is bool ||
        message is DateTime ||
        message is String) {
      if (formatMarkdown) {
        log('Formatting message to Markdown', isProcessing: true);
        formattedMessage = escapeMarkdownV2(message.toString());
        selectedParseMode = 'MarkdownV2';
      } else {
        formattedMessage = message.toString();
      }
    } else if (message is List || message is Map) {
      log('Formatting message to JSON', isProcessing: true);
      formattedMessage = formatJson(message);
      selectedParseMode = 'MarkdownV2';
    }
    final text = formattedMessage.toString().trim();
    if (text.length >= 4096) {
      throw ArgumentError(
        'Message is too long (${text.length} characters). '
        'Telegram messages must be less or equal 4096 characters.',
      );
    }
    final payload = <String, String>{
      'chat_id': chatID,
      'text': text,
      if (selectedParseMode != null) 'parse_mode': selectedParseMode,
    };

    final res = await http.post(url, body: payload);
    if (res.statusCode != 200) {
      log('Failed to send message: ${res.statusCode}');
      throw HttpException(
        'Failed to send message: ${res.statusCode}\n${res.body}',
      );
    }
  }

  @override
  Future<void> sendFile(File file) async {
    log('Checking file ${file.path} existence', isProcessing: true);
    if (!file.existsSync()) {
      throw ArgumentError('File does not exist: ${file.path}');
    }
    log('Lookup mime type', isProcessing: true);

    final mimeType = lookupMimeType(file.path);

    final request =
        http.MultipartRequest('POST', buildUrl('sendDocument'))
          ..fields['chat_id'] = chatID
          ..files.add(
            await http.MultipartFile.fromPath(
              'document',
              file.path,
              contentType: mimeType != null ? MediaType.parse(mimeType) : null,
            ),
          );

    log('Sending file to ${request.url}', isProcessing: true);

    final response = await request.send();
    if (response.statusCode != 200) {
      log('Failed to send file');
      final body = await response.stream.bytesToString();
      throw HttpException('Failed to send file: ${response.statusCode}\n$body');
    }
    log('File sent successfully: ${file.path}');
  }

  @override
  Future<void> getUpdates({int? limit}) async {
    final url = buildUrl('getUpdates', {'limit': limit?.toString()});
    log('Fetching updates from $url', isProcessing: true);

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw HttpException(
        'Failed to fetch updates: ${res.statusCode}\n${res.body}',
      );
    }
    log('Updates fetched successfully');
    log('Response: ${res.body}');
  }
}
