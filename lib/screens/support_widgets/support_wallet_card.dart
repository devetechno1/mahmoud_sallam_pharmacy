import 'package:flutter/material.dart';
import '../../my_theme.dart';
import '../../helpers/main_helpers.dart';
import '../../locale/custom_localization.dart';
import '../../constants/app_dimensions.dart';
import '../../custom/device_info.dart';

class SupportWalletCard extends StatelessWidget {
  final dynamic balanceDetails;

  const SupportWalletCard({
    Key? key,
    required this.balanceDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (balanceDetails == null) return const SizedBox.shrink();

    return Container(
      width: DeviceInfo(context).width! / 2.3,
      height: 90,
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusNormal)),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: AppDimensions.paddingDefault),
            child: Text(
              'wallet_balance_ucf'.tr(context: context),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              convertPrice(balanceDetails.balance),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const Spacer(),
          Text(
            "${'last_recharged'.tr(context: context)} : ${balanceDetails.last_recharged}",
            style: const TextStyle(
              color: MyTheme.light_grey,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer()
        ],
      ),
    );
  }
}
