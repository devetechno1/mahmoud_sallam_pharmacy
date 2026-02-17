import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/custom/box_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerHelper {
  Widget buildBasicShimmer(
      {double height = double.infinity,
      double width = double.infinity,
      double radius = 6}) {
    return Shimmer.fromColors(
      baseColor: MyTheme.shimmer_base,
      highlightColor: MyTheme.shimmer_highlighted,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecorations.buildBoxDecoration_1(radius: radius),
      ),
    );
  }

  static Widget loadingItemBuilder(int index) {
    return Shimmer.fromColors(
      baseColor: MyTheme.shimmer_base,
      highlightColor: MyTheme.shimmer_highlighted,
      child: Container(
        height: (index + 1) % 2 != 0 ? 250 : 300,
        width: double.infinity,
        decoration: BoxDecorations.buildBoxDecoration_1(),
      ),
    );
  }

  Widget buildCircleShimmer(
      {double height = double.infinity,
      double? width = double.infinity,
      BorderRadius radius = BorderRadius.zero,
      Color color = const Color.fromARGB(255, 224, 223, 223)}) {
    return Shimmer.fromColors(
      baseColor: color,
      highlightColor: MyTheme.shimmer_highlighted,
      child:
          // Container(
          //   height: height,
          //   width: width,
          //   decoration:
          //       BoxDecoration(borderRadius: radius, color: MyTheme.shimmer_base),
          // ),
          SizedBox(
        width: height,
        height: width,
        child: CircularProgressIndicator(
          //  value: currentValue / totalValue,
          // backgroundColor: MyTheme.shimmer_base,
          valueColor: AlwaysStoppedAnimation<Color>(MyTheme.shimmer_base),
          strokeWidth: 4.0,
          strokeCap: StrokeCap.round,
        ),
      ),
    );
  }

  Widget buildBasicShimmerCustomRadius(
      {double height = double.infinity,
      double? width = double.infinity,
      BorderRadius radius = BorderRadius.zero,
      Color color = Colors.grey}) {
    return Shimmer.fromColors(
      baseColor: color,
      highlightColor: MyTheme.shimmer_highlighted,
      child: Container(
        height: height,
        width: width,
        decoration:
            BoxDecoration(borderRadius: radius, color: MyTheme.shimmer_base),
      ),
    );
  }

  ListView buildListShimmer({item_count = 10, item_height = 100.0}) {
    return ListView.builder(
      itemCount: item_count,
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
              top: 0.0, left: 16.0, right: 16.0, bottom: 16.0),
          child: ShimmerHelper().buildBasicShimmer(height: item_height),
        );
      },
    );
  }

  MasonryGridView buildProductGridShimmer(
      {required int crossAxisCount, scontroller, item_count = 10}) {
    return MasonryGridView.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        itemCount: item_count,
        shrinkWrap: true,
        padding: const EdgeInsets.only(
            top: AppDimensions.paddingLarge, bottom: 10, left: 18, right: 18),
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return shimmerInGrid(index);
        });
  }

  SliverMasonryGrid buildProductSliverGridShimmer(
      {required int crossAxisCount, scontroller, item_count = 10}) {
    return SliverMasonryGrid.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childCount: item_count,
        itemBuilder: (context, index) {
          return shimmerInGrid(index);
        });
  }

  static Shimmer shimmerInGrid(int index) {
    return Shimmer.fromColors(
      baseColor: MyTheme.shimmer_base,
      highlightColor: MyTheme.shimmer_highlighted,
      child: Container(
        height: (index + 1) % 2 != 0 ? 250 : 300,
        width: double.infinity,
        decoration: BoxDecorations.buildBoxDecoration_1(),
      ),
    );
  }

  GridView buildCategoryCardShimmer({
    int crossAxisCount = 3,
    double aspectRatio = 1.0,
    is_base_category,
  }) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: aspectRatio,
        crossAxisCount: crossAxisCount,
      ),
      itemCount: 18,
      padding: EdgeInsets.only(
          left: 18, right: 18, bottom: is_base_category ? 30 : 0),
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecorations.buildBoxDecoration_1(),
          child: ShimmerHelper().buildBasicShimmer(),
        );
      },
    );
  }

  GridView buildSquareGridShimmer(
      {required int crossAxisCount,
      double childAspectRatio = 1.0,
      scontroller,
      item_count = 10}) {
    return GridView.builder(
      itemCount: item_count,
      controller: scontroller,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: childAspectRatio,
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingSmall),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingSmall),
          child: Shimmer.fromColors(
            baseColor: MyTheme.shimmer_base,
            highlightColor: MyTheme.shimmer_highlighted,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecorations.buildBoxDecoration_1(),
            ),
          ),
        );
      },
    );
  }

  GridView buildHorizontalGridShimmerWithAxisCount(
      {item_count = 10,
      required int crossAxisCount,
      double aspectRatio = 1.0,
      crossAxisSpacing = 10.0,
      mainAxisSpacing = 10.0,
      mainAxisExtent = 100.0,
      controller}) {
    return GridView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingDefault),
        scrollDirection: Axis.horizontal,
        controller: controller,
        itemCount: item_count,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: 10,
            childAspectRatio: aspectRatio,
            mainAxisExtent: mainAxisExtent),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: MyTheme.shimmer_base,
            highlightColor: MyTheme.shimmer_highlighted,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecorations.buildBoxDecoration_1(),
            ),
          );
        });
  }

  GridView buildGridShimmerWithAxisCount(
      {item_count = 10,
      required int crossAxisCount,
      crossAxisSpacing = 10.0,
      mainAxisSpacing = 10.0,
      mainAxisExtent = 100.0,
      double aspectRatio = 1.0,
      Axis scrollDirection = Axis.vertical,
      controller}) {
    return GridView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingDefault),
        scrollDirection: scrollDirection,
        controller: controller,
        itemCount: item_count,
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: aspectRatio,
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            mainAxisExtent: mainAxisExtent),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: MyTheme.shimmer_base,
            highlightColor: MyTheme.shimmer_highlighted,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecorations.buildBoxDecoration_1(),
            ),
          );
        });
  }

  ListView buildSeparatedHorizontalListShimmer(
      {double separationWidth = 16.0,
      int itemCount = 10,
      double itemHeight = 120}) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.paddingDefault),
      separatorBuilder: (context, index) => SizedBox(
        width: separationWidth,
      ),
      itemCount: itemCount,
      scrollDirection: Axis.horizontal,
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: MyTheme.shimmer_base,
          highlightColor: MyTheme.shimmer_highlighted,
          child: Container(
            height: itemHeight,
            width: double.infinity,
            decoration: BoxDecorations.buildBoxDecoration_1(),
          ),
        );
      },
    );
  }
}
