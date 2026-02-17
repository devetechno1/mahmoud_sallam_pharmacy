import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:flutter/material.dart';

import '../../../my_theme.dart';
import '../../../presenter/home_provider.dart';

class BuildTimerRowWidget extends StatelessWidget {
  const BuildTimerRowWidget(this.time, {super.key});

  final CurrentRemainingTime time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: Row(
        children: [
          const Spacer(),
          Column(
            children: [
              TimerCircularContainer(time.days, 365,
                  timeText((time.days).toString(), default_length: 3)),
              const SizedBox(height: 5),
              Text('days'.tr(context: context),
                  style: const TextStyle(color: Colors.grey, fontSize: 10))
            ],
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              TimerCircularContainer(time.hours, 24,
                  timeText((time.hours).toString(), default_length: 2)),
              const SizedBox(height: 5),
              Text('hours'.tr(context: context),
                  style: const TextStyle(color: Colors.grey, fontSize: 10))
            ],
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              TimerCircularContainer(time.min, 60,
                  timeText((time.min).toString(), default_length: 2)),
              const SizedBox(height: 5),
              Text('minutes'.tr(context: context),
                  style: const TextStyle(color: Colors.grey, fontSize: 10))
            ],
          ),
          const SizedBox(width: 5),
          Column(
            children: [
              TimerCircularContainer(time.sec, 60,
                  timeText((time.sec).toString(), default_length: 2)),
              const SizedBox(height: 5),
              Text('seconds'.tr(context: context),
                  style: const TextStyle(color: Colors.grey, fontSize: 10))
            ],
          ),
          const SizedBox(width: 10),
          const Column(
            children: [
              ///  Image.asset("assets/flash_deal.png", height: 20, color: MyTheme.golden),
              SizedBox(height: 12),
            ],
          ),
          Row(
            children: [
              Text('shop_more_ucf'.tr(context: context),
                  style:
                      const TextStyle(fontSize: 10, color: Color(0xffA8AFB3))),
              const SizedBox(width: 3),
              const Icon(
                Icons.arrow_forward_outlined,
                size: 10,
                color: MyTheme.grey_153,
              ),
              const SizedBox(width: 10),
            ],
          )
        ],
      ),
    );
  }
}

String timeText(String val, {int default_length = 2}) {
  return val.padLeft(default_length, '0');
}

class TimerCircularContainer extends StatelessWidget {
  const TimerCircularContainer(
    this.currentValue,
    this.totalValue,
    this.timeText, {
    super.key,
  });
  final int currentValue;
  final int totalValue;
  final String timeText;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            value: currentValue / totalValue,
            backgroundColor: const Color.fromARGB(255, 240, 220, 220),
            valueColor: const AlwaysStoppedAnimation<Color>(
                Color.fromARGB(255, 255, 80, 80)),
            strokeWidth: 4.0,
            strokeCap: StrokeCap.round,
          ),
        ),
        Text(
          timeText,
          style: const TextStyle(
            color: Color.fromARGB(228, 218, 29, 29),
            fontSize: 10.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
