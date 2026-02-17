import 'package:flutter/material.dart';

import '../app_config.dart';
import '../data_model/otp_provider_model.dart';
import '../screens/auth/login.dart';

class SelectOTPProviderWidget extends StatelessWidget {
  const SelectOTPProviderWidget({
    super.key,
    this.selectedProvider,
    required this.onSelect,
    this.margin,
  });

  final EdgeInsetsGeometry? margin;
  final OTPProviderModel? selectedProvider;
  final void Function(OTPProviderModel) onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: margin,
      child: Wrap(
        runAlignment: WrapAlignment.center,
        alignment: WrapAlignment.spaceAround,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppDimensions.paddingDefault,
        runSpacing: AppDimensions.paddingLarge,
        children: List.generate(
          AppConfig.businessSettingsData.otpProviders.length,
          (i) {
            final OTPProviderModel otpProvider =
                AppConfig.businessSettingsData.otpProviders[i];

            final String providerName = otpProvider.sendOTPText ?? "OTP";
            return LoginWith3rd(
              onTap: () => onSelect(otpProvider),
              isSelected: selectedProvider == otpProvider,
              name: providerName,
              networkImage: otpProvider.image,
              assetImage: AppImages.otp,
            );
          },
        ),
      ),
    );
  }
}
