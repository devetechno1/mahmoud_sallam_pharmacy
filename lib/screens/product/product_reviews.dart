import 'dart:async';
import 'dart:ui';

import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/constants/app_images.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/review_repositories.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../app_config.dart';

class ProductReviews extends StatefulWidget {
  final int? id;

  const ProductReviews({Key? key, this.id}) : super(key: key);

  @override
  _ProductReviewsState createState() => _ProductReviewsState();
}

class _ProductReviewsState extends State<ProductReviews> {
  final TextEditingController _myReviewTextController = TextEditingController();
  final ScrollController _xcrollController = ScrollController();
  ScrollController scrollController = ScrollController();

  double _my_rating = 0.0;

  final List<dynamic> _reviewList = [];
  bool _isInitial = true;
  int _page = 1;
  int _totalData = 0;
  bool _showLoadingContainer = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchData();

    _xcrollController.addListener(() {
      if (_xcrollController.position.pixels ==
          _xcrollController.position.maxScrollExtent) {
        setState(() {
          _page++;
        });
        _showLoadingContainer = true;
        fetchData();
      }
    });
  }

  fetchData() async {
    final reviewResponse = await ReviewRepository().getReviewResponse(
      widget.id,
      page: _page,
    );
    _reviewList.addAll(reviewResponse.reviews ?? []);
    _isInitial = false;
    _totalData = reviewResponse.meta?.total ?? 0;
    _showLoadingContainer = false;
    setState(() {});
  }

  reset() {
    _reviewList.clear();
    _isInitial = true;
    _totalData = 0;
    _page = 1;
    _showLoadingContainer = false;
    _my_rating = 0.0;
    _myReviewTextController.text = "";
    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    fetchData();
  }

  Future<void> onTapReviewSubmit(context) async {
    if (is_logged_in.$ == false) {
      ToastComponent.showDialog(
        'you_need_to_login_to_give_a_review'.tr(context: context),
      );
      return;
    }

    //return;
    final myReviewText = _myReviewTextController.text.toString();
    //print(chatText);
    if (myReviewText == "") {
      ToastComponent.showDialog(
        'review_can_not_empty_warning'.tr(context: context),
      );
      return;
    } else if (_my_rating < 1.0) {
      ToastComponent.showDialog(
        'at_least_one_star_must_be_given'.tr(context: context),
      );
      return;
    }

    final reviewSubmitResponse = await ReviewRepository()
        .getReviewSubmitResponse(widget.id, _my_rating.toInt(), myReviewText);

    if (!mounted) return;

    if (reviewSubmitResponse.result == false) {
      ToastComponent.showDialog(
        reviewSubmitResponse.message,
        isError: true,
      );
      return;
    }

    ToastComponent.showDialog(
      reviewSubmitResponse.message,
    );

    reset();
    fetchData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _xcrollController.dispose();
    _myReviewTextController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: buildAppBar(context),
          body: Stack(
            children: [
              RefreshIndicator(
                color: Theme.of(context).primaryColor,
                backgroundColor: Colors.white,
                onRefresh: _onRefresh,
                displacement: 0,
                child: CustomScrollView(
                  controller: _xcrollController,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Padding(
                          padding: const EdgeInsets.all(
                              AppDimensions.paddingDefault),
                          child: buildProductReviewsList(),
                        ),
                        Container(
                          height: 120,
                        )
                      ]),
                    )
                  ],
                ),
              ), //original

              Align(
                alignment: Alignment.bottomCenter,
                child: buildBottomBar(context),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: buildLoadingContainer()),
            ],
          )),
    );
  }

  ClipRRect buildBottomBar(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration:
              BoxDecoration(color: Colors.white54.withValues(alpha: 0.6)),
          height: 120,
          //color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(
                top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
            child: buildGiveReviewSection(context),
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
              app_language_rtl.$!
                  ? CupertinoIcons.arrow_right
                  : CupertinoIcons.arrow_left,
              color: MyTheme.dark_grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        'reviews_ucf'.tr(context: context),
        style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  Widget? buildProductReviewsList() {
    if (_isInitial && _reviewList.isEmpty) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildListShimmer(item_count: 10, item_height: 75.0));
    } else if (_reviewList.isNotEmpty) {
      return SingleChildScrollView(
        child: ListView.builder(
          controller: scrollController,
          itemCount: _reviewList.length,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: buildProductReviewsItem(index),
            );
          },
        ),
      );
    } else if (_totalData == 0) {
      return Container(
        height: 300,
        child: Center(
            child: Text('no_reviews_yet_be_the_first'.tr(context: context))),
      );
    } else {
      return emptyWidget; // should never be happening
    }
  }

  Padding buildProductReviewsItem(index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusVeryLarge),
                border: Border.all(
                    color: const Color.fromRGBO(112, 112, 112, .3), width: 1),
                //shape: BoxShape.rectangle,
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusVeryLarge),
                child: FadeInImage.assetNetwork(
                  placeholder: AppImages.placeholder,
                  image: _reviewList[index].avatar,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  width: 180,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        bottom: AppDimensions.paddingDefault,
                        left: AppDimensions.paddingDefault),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          _reviewList[index].user_name,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 13,
                              height: 1.6,
                              fontWeight: FontWeight.w600),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppDimensions.paddingSmallExtra,
                              right: AppDimensions.paddingDefault),
                          child: Text(
                            textDirection: TextDirection.ltr,
                            _reviewList[index].time,
                            style: const TextStyle(color: MyTheme.medium_grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Padding(
                padding: const EdgeInsets.only(
                    top: 0.0, bottom: 0.0, left: AppDimensions.paddingDefault),
                child: Container(
                  child: RatingBar(
                    itemSize: 12.0,
                    ignoreGestures: true,
                    initialRating: _reviewList[index].rating,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    ratingWidget: RatingWidget(
                      full: const Icon(Icons.star, color: Colors.amber),
                      half: const Icon(Icons.star_half, color: Colors.amber),
                      empty: const Icon(Icons.star,
                          color: Color.fromRGBO(224, 224, 225, 1)),
                    ),
                    itemPadding: const EdgeInsets.only(right: 1.0),
                    onRatingUpdate: (rating) {
                      //print(rating);
                    },
                  ),
                ))
          ]),
          Padding(
            padding: const EdgeInsets.only(left: 56.0),
            child: buildExpandableDescription(index),
          )
        ],
      ),
    );
  }

  ExpandableNotifier buildExpandableDescription(index) {
    return ExpandableNotifier(
        child: ScrollOnExpand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expandable(
            collapsed: Container(
                height: _reviewList[index].comment.length > 100 ? 32 : 16,
                child: Text(_reviewList[index].comment,
                    style: const TextStyle(color: MyTheme.font_grey))),
            expanded: Container(
                child: Text(_reviewList[index].comment,
                    style: const TextStyle(color: MyTheme.font_grey))),
          ),
          _reviewList[index].comment.length > 100
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Builder(
                      builder: (context) {
                        final controller = ExpandableController.of(context)!;
                        return Btn.basic(
                          child: Text(
                            !controller.expanded
                                ? 'view_more'.tr(context: context)
                                : 'show_less_ucf'.tr(context: context),
                            style: const TextStyle(
                                color: MyTheme.font_grey, fontSize: 11),
                          ),
                          onPressed: () {
                            controller.toggle();
                          },
                        );
                      },
                    ),
                  ],
                )
              : emptyWidget,
        ],
      ),
    ));
  }

  Container buildLoadingContainer() {
    return Container(
      height: _showLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalData == _reviewList.length
            ? 'no_more_reviews_ucf'.tr(context: context)
            : 'loading_more_reviews_ucf'.tr(context: context)),
      ),
    );
  }

  Column buildGiveReviewSection(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
              top: AppDimensions.paddingSmall,
              bottom: AppDimensions.paddingSmall),
          child: RatingBar.builder(
            itemSize: 20.0,
            initialRating: _my_rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            glowColor: Colors.amber,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) {
              return const Icon(Icons.star, color: Colors.amber);
            },
            onRatingUpdate: (rating) {
              setState(() {
                _my_rating = rating;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: 40,
              width: (MediaQuery.sizeOf(context).width - 32) * (4 / 5),
              child: TextField(
                autofocus: false,
                maxLines: null,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(125),
                ],
                controller: _myReviewTextController,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromRGBO(251, 251, 251, 1),
                    hintText: 'type_your_review_here'.tr(context: context),
                    hintStyle: const TextStyle(
                        fontSize: 14.0, color: MyTheme.textfield_grey),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: MyTheme.textfield_grey, width: 0.5),
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppDimensions.radiusVeryLarge),
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: MyTheme.medium_grey, width: 0.5),
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppDimensions.radiusVeryLarge),
                      ),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16.0)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingSmall),
              child: GestureDetector(
                onTap: () {
                  onTapReviewSubmit(context);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusVeryLarge),
                    border: Border.all(
                        color: const Color.fromRGBO(112, 112, 112, .3),
                        width: 1),
                    //shape: BoxShape.rectangle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
