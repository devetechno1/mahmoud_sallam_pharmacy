import 'dart:io';

import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/enum_classes.dart';
import 'package:active_ecommerce_cms_demo_app/custom/input_decorations.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/file_helper.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/customer_package_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/file_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/offline_payment_repository.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/offline_wallet_recharge_repository.dart';
import 'package:active_ecommerce_cms_demo_app/screens/orders/order_details.dart';
import 'package:active_ecommerce_cms_demo_app/screens/package/packages.dart';
import 'package:active_ecommerce_cms_demo_app/screens/wallet.dart';
import 'package:active_ecommerce_cms_demo_app/ui_elements/html_content_webview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:image_picker/image_picker.dart';

import '../../app_config.dart';

class OfflineScreen extends StatefulWidget {
  final int? order_id;
  final String? paymentInstruction;
  final String? paymentMethod;

  final PaymentFor? offLinePaymentFor;
  final int? offline_payment_id;
  final double? rechargeAmount;
  final packageId;

  const OfflineScreen(
      {Key? key,
      this.order_id,
      this.paymentInstruction,
      this.offLinePaymentFor,
      this.offline_payment_id,
      this.packageId = "0",
      this.paymentMethod,
      this.rechargeAmount})
      : super(key: key);

  @override
  _OfflineState createState() => _OfflineState();
}

class _OfflineState extends State<OfflineScreen> {
  final ScrollController _mainScrollController = ScrollController();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _trxIdController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _photo_file;
  String? _photo_path = "";
  int? _photo_upload_id = 0;
  late BuildContext loadingcontext;

  Future<void> _onPageRefresh() async {
    reset();
  }

  reset() {
    _amountController.clear();
    _nameController.clear();
    _trxIdController.clear();
    _photo_path = "";
    _photo_upload_id = 0;
    setState(() {});
  }

  Future<void> onPressSubmit() async {
    final String amount = _amountController.text.toString();
    final String name = _nameController.text.toString();
    final String trxId = _trxIdController.text.toString();

    if (amount == "" || name == "" || trxId == "") {
      ToastComponent.showDialog(
        'amount_name_and_transaction_id_are_necessary'.tr(context: context),
      );
      return;
    }

    if (_photo_path == "" || _photo_upload_id == 0) {
      ToastComponent.showDialog(
        'photo_proof_is_necessary'.tr(context: context),
      );
      return;
    }
    loading();
    if (widget.offLinePaymentFor == PaymentFor.WalletRecharge) {
      final submitResponse = await OfflineWalletRechargeRepository()
          .getOfflineWalletRechargeResponse(
        amount: amount,
        name: name,
        trx_id: trxId,
        photo: _photo_upload_id,
      );
      Navigator.pop(loadingcontext);
      if (submitResponse.result == false) {
        ToastComponent.showDialog(
          submitResponse.message,
        );
      } else {
        ToastComponent.showDialog(
          submitResponse.message,
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const Wallet(from_recharge: true);
        }));
      }
    } else if (widget.offLinePaymentFor == PaymentFor.ManualPayment) {
      final submitResponse = await OfflinePaymentRepository()
          .getOfflinePaymentSubmitResponse(
              order_id: widget.order_id,
              amount: amount,
              name: name,
              trx_id: trxId,
              photo: _photo_upload_id);
      Navigator.pop(loadingcontext);
      if (submitResponse.result == false) {
        ToastComponent.showDialog(
          submitResponse.message,
        );
      } else {
        ToastComponent.showDialog(
          submitResponse.message,
        );

        await Navigator.push(context, MaterialPageRoute(builder: (context) {
          return OrderDetails(id: widget.order_id, go_back: false);
        }));
      }
    } else if (widget.offLinePaymentFor == PaymentFor.PackagePay) {
      final submitResponse = await CustomerPackageRepository()
          .offlinePackagePayment(
              packageId: widget.packageId,
              method: widget.paymentMethod,
              trx_id: trxId,
              photo: _photo_upload_id);
      Navigator.pop(loadingcontext);
      if (submitResponse.result == false) {
        ToastComponent.showDialog(
          submitResponse.message,
        );
      } else {
        ToastComponent.showDialog(
          submitResponse.message,
        );

        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const UpdatePackage(goHome: true);
        }));
      }
    }
  }

  Future<void> onPickPhoto(context) async {
    _photo_file = await _picker.pickImage(source: ImageSource.gallery);

    if (_photo_file == null) {
      ToastComponent.showDialog(
        'no_file_is_chosen'.tr(context: context),
      );
      return;
    }

    //return;
    final String base64Image =
        FileHelper.getBase64FormateFile(_photo_file!.path);
    final String fileName = _photo_file!.path.split("/").last;

    final imageUpdateResponse =
        await FileRepository().getSimpleImageUploadResponse(
      base64Image,
      fileName,
    );

    if (imageUpdateResponse.result == false) {
      print(imageUpdateResponse.message);
      ToastComponent.showDialog(
        imageUpdateResponse.message,
      );
      return;
    } else {
      ToastComponent.showDialog(
        imageUpdateResponse.message,
      );

      _photo_path = imageUpdateResponse.path;
      _photo_upload_id = imageUpdateResponse.upload_id;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _trxIdController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _amountController.text = widget.rechargeAmount.toString();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: buildBody(context),
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
        'make_offline_payment_ucf'.tr(context: context),
        style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  Widget buildBody(context) {
    if (is_logged_in == false) {
      return Container(
          height: 100,
          child: Center(
              child: Text(
            'you_need_to_log_in'.tr(context: context),
            style: const TextStyle(color: MyTheme.font_grey),
          )));
    } else {
      return RefreshIndicator(
        color: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        onRefresh: _onPageRefresh,
        displacement: 10,
        child: CustomScrollView(
          controller: _mainScrollController,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingDefault),
                  child: HtmlContentWebView(
                    html: widget.paymentInstruction ?? """<p>Heading</p>""",
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(
                    height: 24,
                  ),
                ),
                buildProfileForm(context)
              ]),
            )
          ],
        ),
      );
    }
  }

  Widget buildProfileForm(context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: AppDimensions.paddingSmall,
          bottom: AppDimensions.paddingSmall,
          left: 16.0,
          right: 16.0),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
              child: Text(
                'all_marked_fields_are_mandatory'.tr(context: context),
                style: const TextStyle(
                    color: MyTheme.grey_153,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.0),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
              child: Text(
                'correctly_fill_up_the_necessary_information'
                    .tr(context: context),
                style: const TextStyle(color: MyTheme.grey_153, fontSize: 14.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: AppDimensions.paddingSmallExtra),
              child: Text(
                "${'amount_ucf'.tr(context: context)}*",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
              child: Container(
                height: 36,
                child: TextField(
                  controller: _amountController,
                  autofocus: false,
                  decoration: InputDecorations.buildInputDecoration_1(
                      hint_text: 'twelve_thousand_only'.tr(context: context)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: AppDimensions.paddingSmallExtra),
              child: Text(
                "${'name_ucf'.tr(context: context)}*",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
              child: Container(
                height: 36,
                child: TextField(
                  controller: _nameController,
                  autofocus: false,
                  decoration: InputDecorations.buildInputDecoration_1(
                      hint_text: 'name_ucf'.tr(context: context)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: AppDimensions.paddingSmallExtra),
              child: Text(
                "${'transaction_id_ucf'.tr(context: context)}*",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSmall),
              child: Container(
                height: 36,
                child: TextField(
                  controller: _trxIdController,
                  autofocus: false,
                  decoration: InputDecorations.buildInputDecoration_1(
                      hint_text: "BNI-4654321354"),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  bottom: AppDimensions.paddingSmallExtra),
              child: Text(
                "${'photo_proof_ucf'.tr(context: context)}* (${'only_image_file_allowed'.tr(context: context)})",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Container(
                    width: 180,
                    height: 36,
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: MyTheme.textfield_grey, width: 1),
                        borderRadius: const BorderRadius.all(
                            Radius.circular(AppDimensions.radiusSmall))),
                    child: Btn.basic(
                      minWidth: MediaQuery.sizeOf(context).width,
                      color: MyTheme.medium_grey,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(AppDimensions.radiusSmall))),
                      child: Text(
                        'photo_proof_ucf'.tr(context: context),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                      onPressed: () {
                        onPickPhoto(context);
                      },
                    ),
                  ),
                ),
                _photo_path != ""
                    ? Padding(
                        padding:
                            const EdgeInsets.all(AppDimensions.paddingSmall),
                        child: Text('selected_ucf'.tr(context: context)),
                      )
                    : emptyWidget
              ],
            ),
            if (_photo_file != null)
              Center(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSmall)),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).shortestSide * .5,
                    maxWidth: MediaQuery.sizeOf(context).shortestSide * .5,
                  ),
                  child: Image.file(File(_photo_file!.path)),
                ),
              ),
            Row(
              children: [
                const Spacer(),
                Padding(
                  padding:
                      const EdgeInsets.only(top: AppDimensions.paddingDefault),
                  child: Container(
                    width: 120,
                    height: 36,
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: MyTheme.textfield_grey, width: 1),
                        borderRadius: const BorderRadius.all(
                            Radius.circular(AppDimensions.radiusSmall))),
                    child: Btn.basic(
                      minWidth: MediaQuery.sizeOf(context).width,
                      color: Theme.of(context).primaryColor,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(AppDimensions.radiusSmall))),
                      child: Text(
                        'submit_ucf'.tr(context: context) + "",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                      onPressed: () {
                        onPressSubmit();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  loading() {
    showDialog(
        context: context,
        builder: (context) {
          loadingcontext = context;
          return AlertDialog(
              content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(
                width: 10,
              ),
              Text("${'please_wait_ucf'.tr(context: context)}"),
            ],
          ));
        });
  }
}
