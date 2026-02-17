import 'package:flutter/material.dart';
import '../../helpers/shared_value_helper.dart';
import '../../locale/custom_localization.dart';
import '../../constants/app_images.dart';

class SupportHelpBubble extends StatelessWidget {
  const SupportHelpBubble({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 42;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsetsDirectional.only(start: 28, end: 12),
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 100, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${user_name.$}, ${'hello'.tr(context: context)}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.35,
                    color: Color(0xFF4A4A4A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'how_can_we_help'.tr(context: context),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.35,
                    color: Color(0xFF4A4A4A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            start: 10,
            top: 7,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x16000000),
                        blurRadius: 10,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      AppImages.applogo,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  left: -2,
                  bottom: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
