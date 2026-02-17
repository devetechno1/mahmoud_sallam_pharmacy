import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import '../../locale/custom_localization.dart';

class SupportAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onClose;
  final Widget? rightWidget;

  const SupportAppBar({Key? key, this.onClose, this.rightWidget}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(110);

  @override
  Widget build(BuildContext context) {
    final backGroundColor = Theme.of(context).primaryColor;

    return Stack(
      children: [
        Container(
          color: backGroundColor),
        Align(
          alignment: Alignment.bottomCenter,
          child: ClipPath(
            clipper: WaveClipperTwo(reverse: true),
            child: Container(
              height: 80,
              color: Colors.grey.shade200,
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SizedBox(
              height: 50,
              child: Row(
                children: [
                  InkWell(
                    onTap: onClose ?? () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.close, color: Colors.white, size: 25),
                    ),
                  ),
                  const Spacer(),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'hi_welcome_to_all_lower'.tr(context: context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const WidgetSpan(child: SizedBox(width: 2)),
                        TextSpan(
                          text: 'app_name'.tr(context: context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                   child: Center(
                      child: rightWidget ??
                          Icon(
                            Icons.chat_bubble_outline,
                            color: backGroundColor,
                            size: 22,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
