import 'dart:ui';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/home_search_box.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/screens/filter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data_model/address_response.dart';
import '../../../presenter/home_provider.dart';

class BuildAppBar extends StatelessWidget {
  const BuildAppBar({
    super.key,
    required this.context,
    required this.showAddress,
  });

  final BuildContext context;
  final bool showAddress;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      floating: true,
      delegate: HomeAppBarDelegate(
        context: context,
        showAddress: showAddress,
        topPadding: MediaQuery.paddingOf(context).top,
      ),
    );
  }
}

class HomeAppBarDelegate extends SliverPersistentHeaderDelegate {
  final BuildContext context;
  final bool showAddress;
  final double topPadding;

  HomeAppBarDelegate({
    required this.context,
    required this.showAddress,
    required this.topPadding,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double baseMaxExtent = 125.0 + topPadding;
    final double baseMinExtent = kToolbarHeight + topPadding;
    final double addressHeight = showAddress ? 30.0 : 0.0;

    final double maxExtent = baseMaxExtent + addressHeight;
    final double minExtent = baseMinExtent + addressHeight;

    // Calculate expansion percentage: 1.0 = expanded, 0.0 = collapsed
    // shrinkOffset goes from 0 to (maxExtent - minExtent)
    final double t =
        (1.0 - (shrinkOffset / (maxExtent - minExtent))).clamp(0.0, 1.0);

    // Logo Constants
    const double logoCollapsedHeight = 30.0;
    const double logoExpandedHeight = 60.0;
    const double logoCollapsedWidth = 30.0;
    const double logoExpandedWidth = 60.0;

    // Search Box Constants
    const double searchBoxHeight = 34.0;

    // Interpolated Values
    final double logoHeight =
        lerpDouble(logoCollapsedHeight, logoExpandedHeight, t)!;
    final double logoWidth =
        lerpDouble(logoCollapsedWidth, logoExpandedWidth, t)!;

    // Logo moves DOWN from Expanded Top to Collapsed Center
    // Expanded Top: topPadding + 10
    // Collapsed Top: topPadding + (kToolbarHeight - logoCollapsedHeight) / 2
    final double logoExpandedTop = topPadding + 10;
    final double logoCollapsedTop =
        topPadding + (kToolbarHeight - logoCollapsedHeight) / 2;
    final double logoTop = lerpDouble(logoCollapsedTop, logoExpandedTop, t)!;

    final double logoStart = lerpDouble(16, (screenWidth - logoWidth) / 2, t)!;

    // Search Box moves UP from Expanded Bottom to Collapsed Center
    // Expanded Top: topPadding + 80
    // Collapsed Top: topPadding + (kToolbarHeight - searchBoxHeight) / 2
    final double searchExpandedTop = topPadding + 80;
    final double searchCollapsedTop =
        topPadding + (kToolbarHeight - searchBoxHeight) / 2;
    final double searchTop =
        lerpDouble(searchCollapsedTop, searchExpandedTop, t)!;

    final double searchStart = lerpDouble(16 + logoCollapsedWidth + 10, 16, t)!;

    return ColoredBox(
      color: Theme.of(context).primaryColor,
      child: Stack(
        children: [
          // Logo Animation
          PositionedDirectional(
            top: logoTop,
            start: logoStart,
            width: logoWidth,
            height: logoHeight,
            child: Image.asset(
              AppImages.squareLogo,
              fit: BoxFit.contain,
            ),
          ),
          // Search Box Animation
          PositionedDirectional(
            top: searchTop,
            start: searchStart,
            end: 16,
            height: searchBoxHeight,
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Filter())),
              child: HomeSearchBox(context: context),
            ),
          ),
          // Address Widget
          if (showAddress)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: addressHeight,
              child: const AddressAppBarWidget(),
            ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 125.0 + topPadding + (showAddress ? 30.0 : 0.0);

  @override
  double get minExtent =>
      kToolbarHeight + topPadding + (showAddress ? 30.0 : 0.0);

  @override
  bool shouldRebuild(covariant HomeAppBarDelegate oldDelegate) {
    return oldDelegate.showAddress != showAddress ||
        oldDelegate.topPadding != topPadding;
  }
}

class AddressAppBarWidget extends StatelessWidget {
  const AddressAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.read<HomeProvider>().handleAddressNavigation(false),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingDefault,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: Row(
          spacing: AppDimensions.paddingSmall,
          children: [
            const Icon(Icons.location_on_outlined, color: Colors.white70),
            Expanded(
              child: Selector<HomeProvider,
                  ({bool isLoadingAddress, Address? defaultAddress})>(
                selector: (_, p) => (
                  defaultAddress: p.defaultAddress,
                  isLoadingAddress: p.isLoadingAddress
                ),
                builder: (context, p, child) {
                  return Text(
                    p.isLoadingAddress
                        ? "is_loading".tr(context: context)
                        : p.defaultAddress == null
                            ? "add_default_address".tr(context: context)
                            : "${p.defaultAddress?.city_name}, ${p.defaultAddress?.state_name}, ${p.defaultAddress?.country_name}",
                    style: const TextStyle(color: Colors.white70),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
