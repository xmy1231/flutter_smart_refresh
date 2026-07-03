import 'package:flutter/material.dart';
import 'package:flutter_smart_refresh/flutter_smart_refresh.dart';
import '../../../l10n/app_localizations.dart';

class QQChatListDemo extends StatefulWidget {
  const QQChatListDemo({super.key});

  @override
  State<QQChatListDemo> createState() => _QQChatListDemoState();
}

class _QQChatListDemoState extends State<QQChatListDemo> {
  final RefreshController _controller = RefreshController();
  final List<_ChatMessage> _messages = _generateMessages(20);

  static List<_ChatMessage> _generateMessages(int count) {
    return List.generate(count, (i) {
      final isMe = i % 3 != 0;
      return _ChatMessage(
        text: 'This is a chat message #${i + 1}. Hello from ${isMe ? "我" : "好友"}!',
        isMe: isMe,
        time: '${10 + i % 12}:${(i * 7) % 60}',
      );
    });
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() => _messages.insertAll(0, _generateMessages(5)));
    _controller.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (_messages.length >= 60) {
      _controller.loadNoData();
      return;
    }
    setState(() => _messages.addAll(_generateMessages(5)));
    _controller.loadComplete();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context)!.current;
    return Scaffold(
      appBar: AppBar(title: Text(s.appBarQqChat)),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/qqbg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: true,
          reverse: true,
          controller: _controller,
          header: const ClassicHeader(),
          footer: const ClassicFooter(),
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (_, i) => _ChatBubble(message: _messages[i]),
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isMe;
  final String time;
  _ChatMessage({required this.text, required this.isMe, required this.time});
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            message.time,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!message.isMe) ...[
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isMe ? Colors.green[100] : Colors.white,
                    borderRadius: BorderRadius.circular(12).copyWith(
                      bottomRight: message.isMe ? Radius.zero : null,
                      bottomLeft: !message.isMe ? Radius.zero : null,
                    ),
                  ),
                  child: Text(message.text, style: const TextStyle(fontSize: 14)),
                ),
              ),
              if (message.isMe) ...[
                const SizedBox(width: 8),
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
