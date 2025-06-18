import 'dart:io';

import 'package:tinygram/src/tinygram_bot.dart';
import 'package:tinygram/src/tinygram_chat.dart';

const _botToken = '<Your Bot Token Here>';
const _chatId = '<Your Chat ID Here>';

void main() => tinygram();

Future<void> tinygram() async {
  final bot = TinygramBotImpl(token: _botToken, chat: TinygramChat(_chatId));
  // Fetch updates (useful for discovering chat IDs)
  await bot.getUpdates(limit: 1);

  // Send current timestamp
  await bot.sendMessage(DateTime.now());

  // Send plain text (Markdown symbols will not be parsed)
  await bot.sendMessage(
    'Hello, *Tinygram!* This message is sent as plain text.',
    formatMarkdown: false,
  );

  // Send formatted message using MarkdownV2
  await bot.sendMessage(
    'Hello, *Tinygram!* This message uses _MarkdownV2_ formatting. '
    'Check out [tinygram](https://github.com/4uzhoy/tinygram)',
    formatMarkdown: true,
  );

  // Send a simple text message before JSON block
  await bot.sendMessage('And here is a JSON-formatted message:');

  // Send a single object as pretty JSON
  await bot.sendMessage(User.alice().toJson());

  // Send a list of objects as pretty JSON
  await bot.sendMessage(
    UserCollection(users: [User.bob(), User.alice()]).toJson(),
  );

  // Send a basic list
  await bot.sendMessage(List<int>.generate(5, (i) => i + 1, growable: false));

  // Send a map
  await bot.sendMessage({
    'key': 'value',
    'number': 42,
    'list': List<int>.generate(3, (i) => i + 1, growable: false),
  });

  // Send a file (example Dart source)
  await bot.sendMessage('And finally, a file:');
  await bot.sendFile(File('example/example.dart'));
}

final class UserCollection {
  const UserCollection({required this.users});
  factory UserCollection.fromJson(Map<String, dynamic> json) => UserCollection(
    users:
        (json['users'] as List<dynamic>)
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .toList(),
  );

  final List<User> users;

  List<dynamic> toJson() => List<dynamic>.from(users.map((e) => e.toJson()));

  @override
  String toString() => 'UserCollection(users: $users)';
}

/// For demonstration purposes, we define a simple User class.
final class User {
  const User({required this.name, required this.age});
  factory User.fromJson(Map<String, dynamic> json) =>
      User(name: json['name'] as String, age: json['age'] as int);
  factory User.bob() => const User(name: 'Bob', age: 30);
  factory User.alice() => const User(name: 'Alice', age: 30);
  final String name;
  final int age;

  Map<String, dynamic> toJson() => <String, dynamic>{'name': name, 'age': age};

  @override
  String toString() => 'User(name: $name, age: $age)';

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.name == name && other.age == age;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => name.hashCode ^ age.hashCode;
}
