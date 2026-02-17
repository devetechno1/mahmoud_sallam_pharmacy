import 'package:active_ecommerce_cms_demo_app/helpers/string_helper.dart';
import 'package:flutter/material.dart';

class RowTimeDataWidget extends StatelessWidget {
  const RowTimeDataWidget(
      {super.key,
      required this.time,
      this.isFirst = false,
      required this.timeType});
  final String time;
  final String timeType;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
        ),
        children: [
          if (!isFirst) const TextSpan(text: '  :  '),
          TextSpan(text: time.timeText()),
          const WidgetSpan(child: SizedBox(width: 4)),
          TextSpan(
              text: timeType,
              style: const TextStyle(color: Colors.white, fontSize: 9)),
        ],
      ),
    );
    // return Row(
    //   children: [
    //     if(!isFirst)  const Padding(
    //       padding: EdgeInsets.symmetric(horizontal: 10),
    //       child: Text(':',style: TextStyle(color: Colors.white)),
    //     ),
    //     Text(
    //       time.timeText(),
    //       style: const TextStyle(
    //         color:Colors.white,
    //         fontSize: 14.0,
    //         fontWeight: FontWeight.w600,
    //       ),
    //     ),
    //     const SizedBox(width: 4),
    //     Text( timeType, style: const TextStyle(color: Colors.white, fontSize: 9)),
    //   ],
    // );
  }
}
