import 'package:active_ecommerce_cms_demo_app/custom/box_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/currency_response.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/system_config.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/currency_presenter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_config.dart';
import '../presenter/home_provider.dart';
import 'auth/custom_otp.dart';

class CurrencyChange extends StatefulWidget {
  const CurrencyChange({Key? key}) : super(key: key);

  @override
  _CurrencyChangeState createState() => _CurrencyChangeState();
}

class _CurrencyChangeState extends State<CurrencyChange> {
  onchange(CurrencyInfo currencyInfo) {
    SystemConfig.systemCurrency = currencyInfo;
    system_currency.$ = currencyInfo.id;
    setState(() {});

    system_currency.save().then((value) {
      context.read<HomeProvider>().onRefresh();
      goHome(context);
    });
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
                onRefresh: () {
                  return Provider.of<CurrencyPresenter>(context, listen: false)
                      .fetchListData();
                },
                displacement: 0,
                child: CustomScrollView(
                  //controller: _mainScrollController,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Padding(
                          padding:
                              const EdgeInsets.all(AppDimensions.paddingMedium),
                          child: buildLanguageMethodList(),
                        ),
                      ]),
                    )
                  ],
                ),
              ),
            ],
          )),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: false,
      leading: Builder(
        builder: (context) => IconButton(
          padding: EdgeInsets.zero,
          icon: UsefulElements.backButton(),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        "${'currency_change_ucf'.tr(context: context)}",
        style: const TextStyle(
            fontSize: 16,
            color: MyTheme.dark_font_grey,
            fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  Consumer<CurrencyPresenter> buildLanguageMethodList() {
    return Consumer<CurrencyPresenter>(
        builder: (context, currencyModel, child) {
      return SingleChildScrollView(
        child: ListView.separated(
          separatorBuilder: (context, index) {
            return const SizedBox(
              height: 14,
              width: 10,
            );
          },
          itemCount: currencyModel.currencyList.length,
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          //padding: EdgeInsets.symmetric(horizontal: 80),

          itemBuilder: (context, index) {
            return buildPaymentMethodItemCard(
                currencyModel.currencyList[index]);
          },
        ),
      );
    });
  }

  Widget buildPaymentMethodItemCard(CurrencyInfo currencyInfo) {
    return GestureDetector(
      onTap: () {
        onchange(currencyInfo);
      },
      child: AnimatedContainer(
        decoration: BoxDecorations.buildBoxDecoration_1().copyWith(
            border: Border.all(
                color: currencyInfo.id == system_currency.$
                    ? Theme.of(context).primaryColor
                    : MyTheme.noColor)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        duration: const Duration(milliseconds: 400),
        child: Row(
          children: [
            Text(
              "${currencyInfo.name} - ${currencyInfo.symbol}",
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(
                  color: MyTheme.font_grey,
                  fontSize: 16,
                  height: 1.6,
                  fontWeight: FontWeight.w400),
            ),
            const Spacer(),
            if (currencyInfo.id == system_currency.$) buildCheckContainer(true)
          ],
        ),
      ),
    );
  }

  Widget buildCheckContainer(bool check) {
    return check
        ? Container(
            height: 16,
            width: 16,
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusDefault),
                color: Colors.green),
            child: const Padding(
              padding: EdgeInsets.all(3),
              child: Icon(Icons.check, color: Colors.white, size: 10),
            ),
          )
        : emptyWidget;
  }
}
