import 'package:test/test.dart';
import 'package:tinygram/src/tinygram_bot.dart';
import 'package:tinygram/src/tinygram_chat.dart';

void main() {
  group('TinygramBotImpl', () {
    const fakeToken = '123:ABC';
    const fakeChatId = '987654321';
    final chat = TinygramChat(fakeChatId);

    test('escapeMarkdown should escape special characters', () {
      final bot = TinygramBotImpl(token: fakeToken, chat: chat);

      const raw = '_*[]()~`>#+-=|{}.!';
      final escaped = bot.escapeMarkdownV2(raw);

      const expectedEscaped = [
        r'\[',
        r'\]',
        r'\(',
        r'\)',
        r'\~',
        r'\`',
        r'\>',
        r'\#',
        r'\+',
        r'\-',
        r'\=',
        r'\|',
        r'\{',
        r'\}',
        r'\.',
        r'\!',
      ];

      for (final symbol in expectedEscaped) {
        expect(
          escaped.contains(symbol),
          isTrue,
          reason: 'Missing $symbol in "$escaped"',
        );
      }
    });

    test('escapeMarkdownV2 should not escape alphanumeric characters', () {
      final bot = TinygramBotImpl(token: fakeToken, chat: chat);

      const raw = 'abcXYZ123';
      final escaped = bot.escapeMarkdownV2(raw);

      expect(escaped, equals(raw));
    });

    test('escapeMarkdownV2 should escape "!"', () {
      final bot = TinygramBotImpl(token: fakeToken, chat: chat);

      const raw = 'Hello!';
      final escaped = bot.escapeMarkdownV2(raw);

      expect(escaped, contains(r'\!'));
    });

    test('formatJson should wrap JSON in Markdown code block', () {
      final bot = TinygramBotImpl(token: fakeToken, chat: chat);
      final json = {'x': 1};

      final output = bot.formatJson(json);

      expect(output, startsWith('```json'));
      expect(output, endsWith('```'));
      expect(output, contains('"x": 1'));
    });

    test('formatJson should wrap and indent JSON as plain code block', () {
      final bot = TinygramBotImpl(token: fakeToken, chat: chat);
      final json = {
        'key': 'value',
        'list': [1, 2, 3],
      };

      final output = bot.formatJson(json);

      expect(output.startsWith('```json\n'), isTrue);
      expect(output.endsWith('\n```'), isTrue);
      expect(output.contains('"key": "value"'), isTrue);
      expect(output.contains('"list": [\n    1,\n    2,\n    3\n  ]'), isTrue);
    });
  });
}
