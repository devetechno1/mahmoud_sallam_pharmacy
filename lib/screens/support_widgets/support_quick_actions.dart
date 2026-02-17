import 'package:flutter/material.dart';
import '../../constants/app_images.dart';
import '../../locale/custom_localization.dart';
import '../../screens/profile.dart' show BottomVerticalCardListItemWidget;

class SupportQuickActions extends StatelessWidget {
  final VoidCallback onOrdersPressed;
  final VoidCallback onAddressesPressed;
  final VoidCallback onWalletPressed;

  const SupportQuickActions({
    Key? key,
    required this.onOrdersPressed,
    required this.onAddressesPressed,
    required this.onWalletPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Items are 1-indexed for the user to match the input
          _buildItem(context, 1, AppImages.orders, 'orders_ucf', onOrdersPressed),
          _buildItem(context, 2, AppImages.location, 'addresses_of_user', onAddressesPressed),
          _buildItem(context, 3, AppImages.wallet, 'my_wallet_ucf', onWalletPressed, showDivider: false),
        ],
      ),
      
    );
  }

  Widget _buildItem(BuildContext context, int index, String icon, String titleKey, VoidCallback onPressed, {bool showDivider = true}) {
      return Column(
        children: [
           BottomVerticalCardListItemWidget(
            icon,
            '$index  ${titleKey.tr(context: context)}',
            onPressed: onPressed,
            showDivider: showDivider,
            isBold: true,
            isDisable: true,
          ),
        ],
      );
  }
}
