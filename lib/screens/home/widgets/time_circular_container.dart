import 'package:flutter/material.dart';

import '../../../app_config.dart';

class TimeCircularContainer extends StatelessWidget {
  const TimeCircularContainer({
    super.key,
    required this.currentValue,
    required this.totalValue,
    required this.timeText,
    required this.timeType,
    // this.defaultTextCircularColor,
  });

  final int currentValue;
  final int totalValue;
  final String timeText;
  final String timeType;
  // final Color? defaultTextCircularColor;
  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CircularProgressIndicator(
              value: currentValue / totalValue,
              backgroundColor: Colors.black,
              // backgroundColor: const Color.fromARGB(255, 240, 220, 220),
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              strokeWidth: 4.0,
              strokeCap: StrokeCap.round,
            ),
          ),
          Positioned(
            bottom: 4,
            left: 4,
            top: 4,
            right: 4,
            child: Builder(
              builder: (context) {
                 final Color  textColor =
                 ((AppConfig.businessSettingsData.isLightFlashDealTextColor )
                    ? Colors.white
                    : Colors.black);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      timeText,
                      style: TextStyle(
                        color:
                            textColor,
                            // Theme.of(context).primaryColor,
                        fontSize: 10.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // SizedBox(width: 12,),
                    Flexible(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(timeType,
                              style: TextStyle(
                                  color:
                                      textColor,
                                      // Theme.of(context).primaryColor,
                                  fontSize: 7))),
                    )),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
