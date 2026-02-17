import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';
import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/category_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/bottom_appbar_index.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/category_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/category_list_n_product/category_products.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

import '../../custom/category_item_card_widget.dart';
import '../../helpers/grid_responsive.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({
    Key? key,
    required this.slug,
    required this.name,
    this.is_base_category = false,
    this.is_top_category = false,
    this.bottomAppbarIndex,
  }) : super(key: key);

  final String slug;
  final String name;
  final bool is_base_category;
  final bool is_top_category;
  final BottomAppbarIndex? bottomAppbarIndex;

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          child: buildAppBar(context),
          preferredSize: Size(
            DeviceInfo(context).width!,
            50,
          ),
        ),
        body: buildBody(),
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: widget.is_base_category || widget.is_top_category
            ? Container(
                height: 0,
              )
            : buildBottomContainer(),
      )
    ]);
  }

  Widget buildBody() {
    return Container(
      color: const Color(0xffECF1F5),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                buildCategoryList(),
                Container(
                  height: widget.is_base_category ? 60 : 90,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: MyTheme.mainColor,
      scrolledUnderElevation: 0.0,
      centerTitle: widget.is_base_category,
      leading: widget.is_base_category
          ? Builder(
              builder: (context) =>
                  UsefulElements.backToMain(go_back: false, color: "black"),
            )
          : Builder(
              builder: (context) => IconButton(
                icon: Icon(
                    app_language_rtl.$!
                        ? CupertinoIcons.arrow_right
                        : CupertinoIcons.arrow_left,
                    color: MyTheme.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
      title: Text(
        getAppBarTitle(),
        style: const TextStyle(
            fontSize: 16,
            color: Color(0xff121423),
            fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  String getAppBarTitle() {
    final String name = widget.is_top_category
        ? 'top_categories_ucf'.tr(context: context)
        : 'categories_ucf'.tr(context: context);

    return name;
  }

  FutureBuilder<CategoryResponse> buildCategoryList() {
    final data = widget.is_top_category
        ? CategoryRepository().getTopCategories()
        : CategoryRepository().getCategories(parent_id: widget.slug);

    final cross = GridResponsive.columnsForWidth(
      context,
      minTileWidth: 160,
      maxXs: 3,
      maxSm: 5,
      maxMd: 7,
      maxLg: 9,
    );
    final ratio = GridResponsive.aspectRatioForWidth(
      context,
      fallback:  0.825,
      maxSm: 0.81,
      maxMd: 0.82,
      maxLg: 0.81,
    );
    return FutureBuilder(
      future: data,
      builder: (context, AsyncSnapshot<CategoryResponse> snapshot) {
        // if getting response is
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SingleChildScrollView(
            child: ShimmerHelper().buildCategoryCardShimmer(
              is_base_category: widget.is_base_category,
              crossAxisCount: cross,
              
            ),
          );
        }
        // if response has issue
        if (snapshot.hasError) {
          return const SizedBox(height: 10);
        } else if (snapshot.hasData) {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              crossAxisCount: cross,
              childAspectRatio: ratio,
            ),
            itemCount: snapshot.data!.categories!.length,
            padding: EdgeInsets.only(
              left: 18,
              right: 18,
              bottom: widget.is_base_category ? 30 : 0,
            ),
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return CategoryItemCardWidget(
                categoryResponse: snapshot.data!,
                index: index,
              );
            },
          );
        } else {
          return SingleChildScrollView(
            child: ShimmerHelper().buildCategoryCardShimmer(
              is_base_category: widget.is_base_category,
              crossAxisCount: cross,
            ),
          );
        }
      },
    );
  }

  Container buildBottomContainer() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      height: widget.is_base_category ? 0 : 80,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingDefault),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.paddingSmall),
              child: Container(
                width: (MediaQuery.sizeOf(context).width - 32),
                height: 40,
                child: Btn.basic(
                  minWidth: MediaQuery.sizeOf(context).width,
                  color: Theme.of(context).primaryColor,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(AppDimensions.radiusSmall))),
                  child: Text(
                    'all_products_of_ucf'.tr(context: context) + " ",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return CategoryProducts(
                            name: widget.name,
                            slug: widget.slug,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
