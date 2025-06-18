## tinygram — tiny but powerful Telegram bot client for Dart 🚀

![Logo](https://raw.githubusercontent.com/4uzhoy/tinygram/main/assets/icologo3_small.png)

### Minimalistic yet capable wrapper for sending messages and files via the Telegram Bot API.

Perfect for:
- bots
- logging tools
- dev alerts
- CI/CD notifications

---

### ✨ Features

- 📩 Send plain text or MarkdownV2-formatted messages  
- 🧾 Pretty-print and send JSON blocks  
- 📎 Upload files (images, logs, documents)  
- 🔍 Fetch updates to discover chat/channel IDs  

---

### 🚀 Getting Started

1. Open Telegram and start a chat with [@BotFather](https://t.me/BotFather)
2. Create a new bot using `/newbot`
3. Set a name and username
4. Add the bot to a group or channel

---

### 🔍 How to Get Chat ID

Use `tinygram.getUpdates()` after sending a message in your group:

```dart
await bot.getUpdates();
```

Find the "chat" object in the response and extract the id.
