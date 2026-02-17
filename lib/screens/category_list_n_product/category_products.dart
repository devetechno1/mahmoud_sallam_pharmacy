import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/constants/app_images.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';
import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/category_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/debouncer.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/category_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/product_repository.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/product_card.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import '../../custom/paged_view/models/page_result.dart';
import '../../custom/paged_view/paged_view.dart';
import '../../data_model/product_mini_response.dart';

class CategoryProducts extends StatefulWidget {
  const CategoryProducts({Key? key, required this.slug, required this.name})
      : super(key: key);
  final String slug;
  final String name;

  @override
  _CategoryProductsState createState() => _CategoryProductsState();
}

class _CategoryProductsState extends State<CategoryProducts> {
  final TextEditingController _searchController = TextEditingController();
  final PagedViewController<Product> controller =
      PagedViewController<Product>();
  final Debouncer debounce = Debouncer(milliseconds: 600);

  String _searchKey = "";
  Category? categoryInfo;
  bool _showSearchBar = false;
  final List<Category> _subCategoryList = [];

  Future<void> getSubCategory() async {
    final res =
        await CategoryRepository().getCategories(parent_id: widget.slug);
    if (res.categories != null) {
      _subCategoryList.clear();
      _subCategoryList.addAll(res.categories!);
    }
    setState(() {});
  }

  Future<void> getCategoryInfo() async {
    final res = await CategoryRepository().getCategoryInfo(widget.slug);
    print(res.categories.toString());
    if (res.categories?.isNotEmpty ?? false) {
      categoryInfo = res.categories?.first;
    }
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCategoryInfo();
    getSubCategory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    debounce.cancel();
    super.dispose();
  }

  Future<PageResult<Product>> _fetchProducts(int page) async {
    try {
      final ProductMiniResponse res = await ProductRepository()
          .getCategoryProducts(id: widget.slug, page: page, name: _searchKey);
      final List<Product> list = res.products ?? [];
      final bool hasMore = list.isNotEmpty;
      return PageResult<Product>(data: list, hasMore: hasMore);
    } catch (_) {
      return const PageResult<Product>(data: [], hasMore: false);
    }
  }

  void reset() {
    _subCategoryList.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_showSearchBar,
      onPopInvokedWithResult: (_, __) => changeSearchMode(false),
      child: Scaffold(
        backgroundColor: MyTheme.mainColor,
        appBar: buildAppBar(),
        body: PagedView<Product>(
          controller: controller,
          fetchPage: _fetchProducts,
          layout: PagedLayout.masonry,
          gridCrossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          padding: const EdgeInsets.only(
            top: AppDimensions.paddingLarge,
            bottom: AppDimensions.paddingSupSmall,
            left: AppDimensions.paddingMedium,
            right: AppDimensions.paddingMedium,
          ),
          itemBuilder: (context, product, index) {
            return ProductCard(
              id: product.id,
              slug: product.slug ?? '',
              image: product.thumbnail_image,
              name: product.name,
              main_price: product.main_price,
              stroked_price: product.stroked_price,   
              discount: product.discount,
              isWholesale: product.isWholesale,
              has_discount: product.has_discount == true,
              searchedText: _searchKey,
              flatdiscount: product.flatdiscount,
            );
          },
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    final double subCatHeight = _subCategoryList.isEmpty ? 0 : 100;
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: DeviceInfo(context).height! / 10 + subCatHeight,
      backgroundColor: MyTheme.mainColor,
      forceMaterialTransparency: true,
      bottom: PreferredSize(
        child: AnimatedContainer(
          height: subCatHeight,
          color: MyTheme.mainColor,
          duration: const Duration(milliseconds: 300),
          child: buildSubCategory(subCatHeight),
        ),
        preferredSize: const Size.fromHeight(-35),
      ),
      title: buildAppBarTitle(),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  Widget buildAppBarTitle() {
    return AnimatedCrossFade(
      firstChild: buildAppBarTitleOption(context),
      secondChild: buildAppBarSearchOption(context),
      firstCurve: Curves.fastOutSlowIn,
      secondCurve: Curves.fastOutSlowIn,
      crossFadeState:
          _showSearchBar ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 500),
    );
  }

  Padding buildAppBarTitleOption(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8, end: 20),
      child: Row(
        children: [
          UsefulElements.backButton(color: "black"),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 10),
              child: Text(
                categoryInfo?.name ?? widget.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(
            width: 20,
            child: GestureDetector(
              onTap: () => changeSearchMode(true),
              child: Image.asset('assets/search.png'),
            ),
          )
        ],
      ),
    );
  }

  Future<void> changeSearchMode(bool inSearchMode) async {
    _showSearchBar = inSearchMode;
    _searchKey = "";
    _searchController.clear();
    if (_showSearchBar) {
      reset();
    } else {
      getSubCategory();
      controller.reset();
    }
  }

  Container buildAppBarSearchOption(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      width: DeviceInfo(context).width,
      height: 40,
      child: TextField(
        controller: _searchController,
        onChanged: (txt) => debounce.call(() => onSearch(txt)),
        onSubmitted: (txt) => onSearch(txt),
        autofocus: false,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () => changeSearchMode(false),
            icon: const Icon(
              Icons.clear,
              color: MyTheme.grey_153,
            ),
          ),
          filled: true,
          fillColor: MyTheme.white.withValues(alpha: 0.6),
          hintText:
              "${'search_products_from'.tr(context: context)} : " + widget.name,
          hintStyle: const TextStyle(fontSize: 14.0, color: MyTheme.font_grey),
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: MyTheme.noColor, width: 0.0),
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusHalfSmall)),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: MyTheme.noColor, width: 0.0),
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusHalfSmall)),
          contentPadding: const EdgeInsets.all(8.0),
        ),
      ),
    );
  }

  void onSearch(String txt) {
    if (txt.trim() == _searchKey) return;
    _searchKey = txt.trim();
    controller.refresh();
  }

  ListView buildSubCategory(double subCatHeight) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return CategoryProducts(
                    name: _subCategoryList[index].name ?? '',
                    slug: _subCategoryList[index].slug!,
                  );
                },
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppDimensions.radiusNormal),
          child: SizedBox(
            width: 80,
            child: Column(
              children: [
                Expanded(
                  flex: 12,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusNormal),
                      child: FadeInImage.assetNetwork(
                        placeholder: AppImages.placeholder,
                        image: _subCategoryList[index].coverImage ?? '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Flexible(
                  flex: 5,
                  child: Text(
                    _subCategoryList[index].name!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(width: 10),
      itemCount: _subCategoryList.length,
    );
  }
}
