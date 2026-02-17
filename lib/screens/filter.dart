import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/reg_ex_inpur_formatter.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/string_helper.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/brand_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/category_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/product_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/shop_repository.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/brand_square_card.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/product_card.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/shop_square_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../custom/paged_view/models/page_result.dart';
import '../custom/paged_view/paged_view.dart';
import '../data_model/brand_response.dart';
import '../data_model/product_mini_response.dart';
import '../data_model/search_suggestion_response.dart';
import '../data_model/shop_response.dart';
import '../helpers/grid_responsive.dart';
import '../repositories/search_repository.dart';
import '../ui_elements/highlighted_searched_word.dart';

class WhichFilter {
  String option_key;
  String name;

  WhichFilter(this.option_key, this.name);

  static List<WhichFilter> getWhichFilterList() {
    return <WhichFilter>[
      WhichFilter('product', 'product_ucf'.tr()),
      WhichFilter('sellers', 'sellers_ucf'.tr()),
      WhichFilter('brands', 'brands_ucf'.tr()),
    ];
  }
}

class Filter extends StatefulWidget {
  const Filter({
    Key? key,
    this.selected_filter = "product",
  }) : super(key: key);

  final String selected_filter;

  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  final _amountValidator = RegExInputFormatter.withRegex(
      '^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$');

  final PagedViewController<Product> _productController =
      PagedViewController<Product>();
  final PagedViewController<Brands> _brandController =
      PagedViewController<Brands>();
  final PagedViewController<Shop> _shopController = PagedViewController<Shop>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  WhichFilter? _selectedFilter;
  String? _givenSelectedFilterOptionKey;
  String? _selectedSort = "";

  final List<WhichFilter> _which_filter_list = WhichFilter.getWhichFilterList();
  List<DropdownMenuItem<WhichFilter>>? _dropdownWhichFilterItems;
  final List<dynamic> _selectedCategories = [];
  final List<dynamic> _selectedBrands = [];

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  // ✅ NEW: flat discount input
  final TextEditingController _flatDiscountController = TextEditingController();

  final List<dynamic> _filterBrandList = [];
  final List<dynamic> _filterCategoryList = [];
  final List<dynamic> _searchSuggestionList = [];

  String? _searchKey = "";

  fetchFilteredBrands() async {
    final filteredBrandResponse = await BrandRepository().getFilterPageBrands();
    _filterBrandList.addAll(filteredBrandResponse.brands!);
    setState(() {});
  }

  fetchFilteredCategories() async {
    final filteredCategoriesResponse =
        await CategoryRepository().getFilterPageCategories();
    _filterCategoryList.addAll(filteredCategoriesResponse.categories!);
    setState(() {});
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _flatDiscountController.dispose(); // ✅ NEW
    super.dispose();
  }

  init() {
    _givenSelectedFilterOptionKey = widget.selected_filter;

    _dropdownWhichFilterItems =
        buildDropdownWhichFilterItems(_which_filter_list);
    _selectedFilter = _dropdownWhichFilterItems![0].value;

    for (int x = 0; x < _dropdownWhichFilterItems!.length; x++) {
      if (_dropdownWhichFilterItems![x].value!.option_key ==
          _givenSelectedFilterOptionKey) {
        _selectedFilter = _dropdownWhichFilterItems![x].value;
      }
    }

    fetchFilteredCategories();
    fetchFilteredBrands();

    if (_selectedFilter!.option_key == "sellers") {
      _shopController.refresh();
    } else if (_selectedFilter!.option_key == "brands") {
      _brandController.refresh();
    } else {
      _productController.refresh();
    }
  }

  Future<PageResult<Product>> _fetchProducts(int page) async {
    try {
      final ProductMiniResponse res =
          await ProductRepository().getFilteredProducts(
        page: page,
        name: _searchKey,
        sort_key: _selectedSort,
        brands: _selectedBrands.join(",").toString(),
        categories: _selectedCategories.join(",").toString(),
        max: _maxPriceController.text.toString(),
        min: _minPriceController.text.toString(),
        flatdiscount: _flatDiscountController.text.toString(), // ✅ NEW
      );

      final List<Product> list = res.products ?? [];
      final bool hasMore = list.isNotEmpty;
      return PageResult<Product>(data: list, hasMore: hasMore);
    } catch (_) {
      return const PageResult<Product>(data: [], hasMore: false);
    }
  }

  Future<PageResult<Brands>> _fetchBrands(int page) async {
    try {
      final BrandResponse res =
          await BrandRepository().getBrands(page: page, name: _searchKey);
      final List<Brands> list = res.brands ?? [];
      final bool hasMore = list.isNotEmpty;
      return PageResult<Brands>(data: list, hasMore: hasMore);
    } catch (_) {
      return const PageResult<Brands>(data: [], hasMore: false);
    }
  }

  Future<PageResult<Shop>> _fetchShops(int page) async {
    try {
      final ShopResponse res =
          await ShopRepository().getShops(page: page, name: _searchKey);
      final List<Shop> list = res.shops ?? [];
      final bool hasMore = list.isNotEmpty;
      return PageResult<Shop>(data: list, hasMore: hasMore);
    } catch (_) {
      return const PageResult<Shop>(data: [], hasMore: false);
    }
  }

  reset() {
    _searchSuggestionList.clear();
    setState(() {});
  }

  void _applyProductFilter() {
    reset();
    _productController.refresh();
  }

  void _onSearchSubmit() {
    reset();
    if (_selectedFilter!.option_key == "sellers") {
      _shopController.refresh();
    } else if (_selectedFilter!.option_key == "brands") {
      _brandController.refresh();
    } else {
      _productController.refresh();
    }
  }

  void _onSortChange() {
    reset();
    _productController.refresh();
  }

  void _onWhichFilterChange() {
    if (_selectedFilter!.option_key == "sellers") {
      _shopController.refresh();
    } else if (_selectedFilter!.option_key == "brands") {
      _brandController.refresh();
    } else {
      _productController.refresh();
    }
  }

  List<DropdownMenuItem<WhichFilter>> buildDropdownWhichFilterItems(
      List whichFilterList) {
    final List<DropdownMenuItem<WhichFilter>> items = [];
    for (WhichFilter which_filter_item
        in whichFilterList as Iterable<WhichFilter>) {
      items.add(
        DropdownMenuItem(
          value: which_filter_item,
          child: Text(which_filter_item.name),
        ),
      );
    }
    return items;
  }

  static const double _refreshEdgeOffset = 150.0;

  @override
  Widget build(BuildContext context) {
    final AppBar appBar = buildAppBar(context);
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        endDrawer: buildFilterDrawer(),
        key: _scaffoldKey,
        backgroundColor: MyTheme.mainColor,
        body: Stack(
          children: [
            Positioned.fill(
              child: _selectedFilter!.option_key == 'product'
                  ? buildProductScrollableList()
                  : (_selectedFilter!.option_key == 'brands'
                      ? buildBrandScrollableList()
                      : buildShopScrollableList()),
            ),
            Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: appBar,
            ),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: MyTheme.mainColor.withValues(alpha: 0.95),
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0.0,
      forceMaterialTransparency: false,
      actions: const [SizedBox()],
      centerTitle: false,
      flexibleSpace: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
        child: Column(
          children: [
            buildTopAppBar(context),
            buildBottomAppBar(context),
          ],
        ),
      ),
    );
  }

  Row buildBottomAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border.symmetric(
                vertical: BorderSide(color: MyTheme.light_grey, width: .5),
                horizontal: BorderSide(
                  color: MyTheme.light_grey,
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            height: 36,
            child: DropdownButton<WhichFilter>(
              dropdownColor: Colors.white,
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusHalfSmall),
              icon: const Icon(Icons.expand_more_rounded, size: 18),
              hint: Text(
                'products_ucf'.tr(context: context),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                ),
              ),
              style: const TextStyle(color: Colors.black, fontSize: 13),
              iconSize: 13,
              underline: emptyWidget,
              value: _selectedFilter,
              items: _dropdownWhichFilterItems,
              isExpanded: true,
              onChanged: (WhichFilter? selectedFilter) {
                setState(() {
                  _selectedFilter = selectedFilter;
                });
                _onWhichFilterChange();
              },
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              _selectedFilter!.option_key == "product"
                  ? _scaffoldKey.currentState!.openEndDrawer()
                  : ToastComponent.showDialog(
                      'you_can_use_sorting_while_searching_for_products'
                          .tr(context: context),
                    );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border.symmetric(
                  vertical: BorderSide(
                    color: MyTheme.light_grey,
                    width: .5,
                  ),
                  horizontal: BorderSide(color: MyTheme.light_grey, width: 1),
                ),
              ),
              height: 36,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'filter_ucf'.tr(context: context),
                    style: const TextStyle(color: Colors.black, fontSize: 13),
                  ),
                  const Icon(Icons.filter_alt_outlined, size: 13),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              _selectedFilter!.option_key == "product"
                  ? showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                            contentPadding: const EdgeInsets.only(
                              top: 16.0,
                              left: 2.0,
                              right: 2.0,
                              bottom: 2.0,
                            ),
                            content: StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState) {
                              return RadioGroup(
                                groupValue: _selectedSort,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSort = value;
                                  });
                                  _onSortChange();
                                  Navigator.pop(context);
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24.0),
                                      child: Text(
                                        'sort_products_by_ucf'
                                            .tr(context: context),
                                      ),
                                    ),
                                    RadioListTile(
                                      dense: true,
                                      value: "",
                                      activeColor: MyTheme.font_grey,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      title: Text(
                                        'default_ucf'.tr(context: context),
                                      ),
                                    ),
                                    RadioListTile(
                                      dense: true,
                                      value: "price_high_to_low",
                                      activeColor: MyTheme.font_grey,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      title: Text(
                                        'price_high_to_low'
                                            .tr(context: context),
                                      ),
                                    ),
                                    RadioListTile(
                                      dense: true,
                                      value: "price_low_to_high",
                                      activeColor: MyTheme.font_grey,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      title: Text(
                                        'price_low_to_high'
                                            .tr(context: context),
                                      ),
                                    ),
                                    RadioListTile(
                                      dense: true,
                                      value: "new_arrival",
                                      activeColor: MyTheme.font_grey,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      title: Text('new_arrival_ucf'
                                          .tr(context: context)),
                                    ),
                                    RadioListTile(
                                      dense: true,
                                      value: "popularity",
                                      activeColor: MyTheme.font_grey,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      title: Text(
                                        'popularity_ucf'.tr(context: context),
                                      ),
                                    ),
                                    RadioListTile(
                                      dense: true,
                                      value: "top_rated",
                                      activeColor: MyTheme.font_grey,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      title: Text(
                                        'top_rated_ucf'.tr(context: context),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            actions: [
                              Btn.basic(
                                child: Text(
                                  'close_all_capital'.tr(context: context),
                                  style: const TextStyle(
                                      color: MyTheme.medium_grey),
                                ),
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                              ),
                            ],
                          ))
                  : ToastComponent.showDialog(
                      'you_can_use_filters_while_searching_for_products'
                          .tr(context: context),
                    );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border.symmetric(
                      vertical:
                          BorderSide(color: MyTheme.light_grey, width: .5),
                      horizontal:
                          BorderSide(color: MyTheme.light_grey, width: 1))),
              height: 36,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'sort_ucf'.tr(context: context),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                  const Icon(
                    Icons.swap_vert,
                    size: 13,
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Row buildTopAppBar(BuildContext context) {
    String searchedWord = '';
    return Row(children: <Widget>[
      IconButton(
        padding: EdgeInsets.zero,
        icon: UsefulElements.backButton(),
        onPressed: () => Navigator.pop(context),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width * .85,
          height: 70,
          child: Padding(
              padding: MediaQuery.viewPaddingOf(context).top > 30
                  ? const EdgeInsets.symmetric(vertical: 15.0, horizontal: 0.0)
                  : const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
              child: TypeAheadField<SearchSuggestionResponse>(
                controller: _searchController,
                suggestionsCallback: (pattern) async {
                  final suggestions = await SearchRepository()
                      .getSearchSuggestionListResponse(
                          query_key: pattern, type: _selectedFilter!.option_key);
                  return suggestions;
                },
                loadingBuilder: (context) {
                  return Container(
                    height: 40,
                    color: Colors.white,
                    child: Center(
                        child: Text('loading_suggestions'.tr(context: context),
                            style: const TextStyle(
                                color: MyTheme.medium_grey))),
                  );
                },
                itemBuilder: (context, suggestion) {
                  String subtitle =
                      "${'searched_for_all_lower'.tr(context: context)} ${suggestion.count} ${'times_all_lower'.tr(context: context)}";
                  if (suggestion.type != "search") {
                    final String key =
                        "${suggestion.type_string?.toLowerCase()}_ucf";
                    final String tr = key.tr(context: context);
                    subtitle =
                        "${tr == key ? suggestion.type_string : tr} ${'found_all_lower'.tr(context: context)}";
                  }
                  final q = suggestion.query ?? '';
                  return Directionality(
                    textDirection: q.direction,
                    child: ListTile(
                      tileColor: Colors.white,
                      dense: true,
                      title: HighlightedSearchedWord(
                        q,
                        searchedText: searchedWord,
                        style: TextStyle(
                          color: suggestion.type != "search"
                              ? Theme.of(context).primaryColor
                              : MyTheme.font_grey,
                        ),
                      ),
                      subtitle: Text(
                        subtitle,
                        style: TextStyle(
                          color: suggestion.type != "search"
                              ? MyTheme.font_grey
                              : MyTheme.medium_grey,
                        ),
                      ),
                    ),
                  );
                },
                onSelected: (s) => onSearch(s.query ?? ''),
                builder: (context, controller, focusNode) {
                  searchedWord = controller.text;
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    obscureText: false,
                    onChanged: (value) => searchedWord = value,
                    onSubmitted: onSearch,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: MyTheme.white,
                        suffixIcon: const Icon(Icons.search,
                            color: MyTheme.medium_grey),
                        hintText: 'search_here_ucf'.tr(context: context),
                        hintStyle: const TextStyle(
                            fontSize: 12.0, color: MyTheme.textfield_grey),
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: MyTheme.noColor, width: 0.5),
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppDimensions.radiusSmall),
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: MyTheme.noColor, width: 1.0),
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppDimensions.radiusSmall),
                          ),
                        ),
                        contentPadding: const EdgeInsetsDirectional.only(
                            start: 8.0, top: 5.0, bottom: 5.0)),
                  );
                },
              )),
        ),
      ),
    ]);
  }

  void onSearch(String query) {
    _searchController.text = query;
    _searchKey = query;
    setState(() {});
    _onSearchSubmit();
  }

  Directionality buildFilterDrawer() {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Drawer(
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.only(top: 50),
          child: Column(
            children: [
              // ✅ Price + Flat Discount block
              Container(
                height: 160,
                padding: const EdgeInsets.all(AppDimensions.paddingDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: AppDimensions.paddingSmall),
                      child: Text(
                        'price_range_ucf'.tr(context: context),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          height: 30,
                          width: 100,
                          margin: const EdgeInsets.only(
                              bottom: AppDimensions.paddingSmall),
                          child: TextField(
                            controller: _minPriceController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [_amountValidator],
                            decoration: InputDecoration(
                                hintText: 'minimum_ucf'.tr(context: context),
                                hintStyle: const TextStyle(
                                    fontSize: 12.0,
                                    color: MyTheme.textfield_grey),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: MyTheme.textfield_grey,
                                      width: 1.0),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                        AppDimensions.radiusSmallExtra),
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: MyTheme.textfield_grey,
                                      width: 2.0),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                        AppDimensions.radiusSmallExtra),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(4.0)),
                          ),
                        ),
                        const Text(" - "),
                        Container(
                          height: 30,
                          width: 100,
                          margin: const EdgeInsets.only(
                              bottom: AppDimensions.paddingSmall),
                          child: TextField(
                            controller: _maxPriceController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [_amountValidator],
                            decoration: InputDecoration(
                                hintText: 'maximum_ucf'.tr(context: context),
                                hintStyle: const TextStyle(
                                    fontSize: 12.0,
                                    color: MyTheme.textfield_grey),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: MyTheme.textfield_grey,
                                      width: 1.0),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                        AppDimensions.radiusSmallExtra),
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: MyTheme.textfield_grey,
                                      width: 2.0),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                        AppDimensions.radiusSmallExtra),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(4.0)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // ✅ NEW: Flat Discount
                    Text(
                      'flat_discount_ucf'.tr(context: context),
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 20,
                      width: 220,
                      child: TextField(
                        controller: _flatDiscountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [_amountValidator],
                        decoration: InputDecoration(
                          hintText: 'flat_discount_ucf'.tr(context: context),
                          hintStyle: const TextStyle(
                              fontSize: 12.0, color: MyTheme.textfield_grey),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: MyTheme.textfield_grey, width: 1.0),
                            borderRadius: BorderRadius.all(
                              Radius.circular(AppDimensions.radiusSmallExtra),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                                color: MyTheme.textfield_grey, width: 2.0),
                            borderRadius: BorderRadius.all(
                              Radius.circular(AppDimensions.radiusSmallExtra),
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(4.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: CustomScrollView(slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'categories_ucf'.tr(context: context),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _filterCategoryList.isEmpty
                          ? SizedBox(
                              height: 100,
                              child: Center(
                                child: Text(
                                  'no_category_is_available'
                                      .tr(context: context),
                                  style: const TextStyle(
                                      color: MyTheme.font_grey),
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              child: buildFilterCategoryList(),
                            ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 16.0),
                        child: Text(
                          'brands_ucf'.tr(context: context),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _filterBrandList.isEmpty
                          ? SizedBox(
                              height: 100,
                              child: Center(
                                child: Text(
                                  'no_brand_is_available'.tr(context: context),
                                  style: const TextStyle(
                                      color: MyTheme.font_grey),
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              child: buildFilterBrandsList(),
                            ),
                    ]),
                  )
                ]),
              ),
              SizedBox(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
                      onPressed: () {
                        _minPriceController.clear();
                        _maxPriceController.clear();
                        _flatDiscountController.clear(); // ✅ NEW
                        setState(() {
                          _selectedCategories.clear();
                          _selectedBrands.clear();
                        });
                      },
                      child: Text(
                        'clear_all_capital'.tr(context: context),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      onPressed: () {
                        final min = _minPriceController.text.toString();
                        final max = _maxPriceController.text.toString();
                        bool apply = true;
                        if (min != "" && max != "") {
                          if (max.compareTo(min) < 0) {
                            ToastComponent.showDialog(
                              'filter_screen_min_max_warning'
                                  .tr(context: context),
                            );
                            apply = false;
                          }
                        }

                        if (apply) {
                          _applyProductFilter();
                        }
                      },
                      child: Text(
                        'apply_all_capital'.tr(context: context),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListView buildFilterBrandsList() {
    return ListView(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: <Widget>[
        ..._filterBrandList
            .map(
              (brand) => CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                title: Text(brand.name),
                value: _selectedBrands.contains(brand.id),
                onChanged: (bool? value) {
                  if (value!) {
                    setState(() {
                      _selectedBrands.add(brand.id);
                    });
                  } else {
                    setState(() {
                      _selectedBrands.remove(brand.id);
                    });
                  }
                },
              ),
            )
            .toList()
      ],
    );
  }

  ListView buildFilterCategoryList() {
    return ListView(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: <Widget>[
        ..._filterCategoryList
            .map(
              (category) => CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                title: Text(category.name),
                value: _selectedCategories.contains(category.id),
                onChanged: (bool? value) {
                  if (value!) {
                    setState(() {
                      _selectedCategories.clear();
                      _selectedCategories.add(category.id);
                    });
                  } else {
                    setState(() {
                      _selectedCategories.remove(category.id);
                    });
                  }
                },
              ),
            )
            .toList()
      ],
    );
  }

  Widget buildProductScrollableList() {
    final double ratio = GridResponsive.aspectRatioForWidth(
      context,
      fallback: 0.59,
      maxSm: 0.64,
      maxMd: 0.67,
      maxLg: 0.69,
    );

    return dataBodyWidget<Product>(
      controller: _productController,
      fetchPage: _fetchProducts,
      ratio: ratio,
      translatedEmptyText: "no_product_is_available",
      itemBuilder: (context, product, index) => ProductCard(
        id: product.id,
        slug: product.slug ?? '',
        image: product.thumbnail_image,
        name: product.name,
        main_price: product.main_price,
        stroked_price: product.stroked_price,
        has_discount: product.has_discount == true,
        discount: product.discount,
        isWholesale: product.isWholesale,
        flatdiscount: product.flatdiscount,
      ),
    );
  }

  Widget buildBrandScrollableList() {
    return dataBodyWidget<Brands>(
      controller: _brandController,
      fetchPage: _fetchBrands,
      translatedEmptyText: "no_brand_is_available",
      itemBuilder: (context, brand, index) => BrandSquareCard(
        id: brand.id,
        slug: brand.slug ?? '',
        image: brand.logo,
        name: brand.name,
      ),
    );
  }

  Widget buildShopScrollableList() {
    final double ratio = GridResponsive.aspectRatioForWidth(context);

    return dataBodyWidget<Shop>(
      controller: _shopController,
      fetchPage: _fetchShops,
      translatedEmptyText: 'no_shop_is_available',
      ratio: ratio,
      itemBuilder: (context, shop, index) => ShopSquareCard(
        id: shop.id,
        shopSlug: shop.slug ?? '',
        image: shop.logo,
        name: shop.name,
        stars: double.parse(shop.rating.toString()),
        flatdiscount: shop.flatdiscount,
      ),
    );
  }

  PagedView<T> dataBodyWidget<T>({
    PagedViewController<T>? controller,
    String? translatedEmptyText,
    int crossAxisCount = 2,
    double ratio = 1,
    required Future<PageResult<T>> Function(int page) fetchPage,
    required Widget Function(BuildContext, T, int) itemBuilder,
  }) {
    return PagedView<T>(
      controller: controller,
      fetchPage: fetchPage,
      layout: PagedLayout.grid,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      gridCrossAxisCount: crossAxisCount,
      gridAspectRatio: ratio,
      refreshEdgeOffset: _refreshEdgeOffset,
      emptyBuilder: translatedEmptyText == null
          ? null
          : (_) => Center(child: Text(translatedEmptyText.tr(context: _))),
      padding: const EdgeInsets.only(
        top: _refreshEdgeOffset,
        bottom: AppDimensions.paddingSupSmall,
        left: AppDimensions.paddingMedium,
        right: AppDimensions.paddingMedium,
      ),
      itemBuilder: itemBuilder,
    );
  }
}
