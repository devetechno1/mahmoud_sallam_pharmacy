import 'package:flutter/material.dart';

enum SupportMsgType { text, orders }

class SupportMsg {
  final SupportMsgType type;
  final String? text;
  final bool isUser;
   
  final Widget? payload;

  const SupportMsg._({
    required this.type,
    required this.isUser,
    this.text,
    this.payload,
  });

  
  factory SupportMsg.user(String text) => SupportMsg._(
        type: SupportMsgType.text,
        isUser: true,
        text: text,
      );

   
  factory SupportMsg.botText(String text) => SupportMsg._(
        type: SupportMsgType.text,
        isUser: false,
        text: text,
      );

  // رسالة بوت من نوع Orders (Widget)
  factory SupportMsg.botOrders(Widget ordersWidget) => SupportMsg._(
        type: SupportMsgType.orders,
        isUser: false,
        payload: ordersWidget,
      );
}

// 3) Widget الرسم
class SupportChatBubble extends StatelessWidget {
  final SupportMsg msg;
  const SupportChatBubble({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isUser;

    // لو الرسالة Orders: نعرض الكونتينر اللي جايلنا زي ما هو
    if (msg.type == SupportMsgType.orders) {
      return Align(
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: msg.payload ?? const SizedBox.shrink(),
        ),
      );
    }

    // رسالة Text عادي
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: isUser ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          msg.text ?? '',
          textAlign: TextAlign.right,
          style: TextStyle(
            color: isUser ? Colors.white : const Color(0xFF4A4A4A),
            fontSize: 14,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
