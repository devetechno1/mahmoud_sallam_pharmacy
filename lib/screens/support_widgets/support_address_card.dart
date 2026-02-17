import 'package:flutter/material.dart';
import '../../my_theme.dart';
import '../../custom/box_decorations.dart';
import '../../locale/custom_localization.dart';
import '../../data_model/address_response.dart' as res;
import '../../constants/app_dimensions.dart';

class SupportAddressCard extends StatelessWidget {
  final res.Address address;
  final int index;

  const SupportAddressCard({
    Key? key,
    required this.address,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String title = "${'address_ucf'.tr(context: context)} ${index + 1}";
    final String addressText = (address.address ?? '').toString();
    final String cityText = (address.city_name ?? '').toString();
    final String stateText = (address.state_name ?? '').toString();
    final String countryText = (address.country_name ?? '').toString();

    return Container(
      width: 280,
      decoration: BoxDecorations.buildBoxDecoration_1().copyWith(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppDimensions.radiusDefault),
            bottomRight: Radius.circular(AppDimensions.radiusDefault),
            bottomLeft: Radius.circular(AppDimensions.radiusDefault),
          ),
          border: Border.all(color: const Color(0xFFE6E6E6)),
        ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: MyTheme.dark_grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            _buildLineData(context, 'address_ucf'.tr(context: context), addressText),
            _buildLineData(context, 'city_ucf'.tr(context: context), cityText),
            _buildLineData(context, 'state_ucf'.tr(context: context), stateText),
            _buildLineData(context, 'country_ucf'.tr(context: context), countryText),
          ],
        ),
      ),
    );
  }

  Widget _buildLineData(BuildContext context, String name, String? body) {
    if (body?.isNotEmpty != true) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 75,
            child: Text(
              name,
              style: const TextStyle(
                color: Color(0xff6B7377),
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          Flexible(
            child: Text(
              body!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: MyTheme.dark_grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
