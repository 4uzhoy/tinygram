import 'dart:io';

import 'package:tinygram/src/tinygram_bot.dart';
import 'package:tinygram/src/tinygram_chat.dart';

const _botToken = '<Your Bot Token Here>';
const _chatId = '<Your Chat ID Here>';

void main() => tinygram();

Future<void> tinygram() async {
  final bot = TinygramBotImpl(
    token: _botToken,
    chatID: const TinygramChat(_chatId).chatID,
  );
  await bot.getUpdates(limit: 1);

  await bot.sendMessage(DateTime.now());
  await bot.sendMessage(
    'Hello, *Tinygram!* Here is a message as plain text, without formatting',
    formatMarkdown: false,
  );
  await bot.sendMessage(
    'Hello, *Tinygram!* Here is a message with _MarkdownV2_ formatting, link to [tinygram](https://github.com/4uzhoy/tinygram)',
    formatMarkdown: true,
  );
  await bot.sendMessage('And here is a message with JSON formatting:');
  await bot.sendMessage(User.alice().toJson());
  await bot.sendMessage(
    UserCollection(users: <User>[User.bob(), User.alice()]).toJson(),
  );
  await bot.sendMessage([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
  await bot.sendMessage({
    'key': 'value',
    'number': 42,
    'list': [1, 2, 3],
  });
  await bot.sendMessage('And here is a file:');
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
