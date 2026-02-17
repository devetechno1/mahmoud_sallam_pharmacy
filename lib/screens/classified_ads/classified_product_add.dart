import 'dart:convert';
import 'package:active_ecommerce_cms_demo_app/constants/app_dimensions.dart';
import 'package:active_ecommerce_cms_demo_app/data_model/category.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:flutter/material.dart';
import '../../app_config.dart';
import '../../custom/aiz_summer_note.dart';
import '../../custom/device_info.dart';
import '../../custom/loading.dart';
import '../../custom/my_widget.dart';
import '../../custom/toast_component.dart';
import '../../custom/useful_elements.dart';
import '../../data_model/uploaded_file_list_response.dart';
import '../../helpers/shared_value_helper.dart';
import '../../my_theme.dart';
import '../../repositories/brand_repository.dart';
import '../../repositories/classified_product_repository.dart';
import '../../repositories/product_repository.dart';
import '../uploads/upload_file.dart';

class ClassifiedProductAdd extends StatefulWidget {
  const ClassifiedProductAdd({Key? key}) : super(key: key);

  @override
  State<ClassifiedProductAdd> createState() => _ClassifiedProductAddState();
}

class _ClassifiedProductAddState extends State<ClassifiedProductAdd> {
  double mHeight = 0.0, mWidth = 0.0;
  bool _generalExpanded = true;
  bool _mediaExpanded = false;
  bool _priceExpanded = false;
  bool _hasFocus = false;

  // Controllers
  final TextEditingController productNameEditTextController =
      TextEditingController();
  final TextEditingController unitEditTextController = TextEditingController();
  final TextEditingController tagEditTextController = TextEditingController();
  final TextEditingController locationTextController = TextEditingController();
  final TextEditingController metaTitleTextController = TextEditingController();
  final TextEditingController metaDescriptionEditTextController =
      TextEditingController();
  final TextEditingController videoLinkController = TextEditingController();
  final TextEditingController unitPriceEditTextController =
      TextEditingController(text: "0");

  final GlobalKey<FlutterSummernoteState> productDescriptionKey = GlobalKey();

  CommonDropDownItemWithChild? selectedCategory;
  final List<CommonDropDownItemWithChild> categories = [];
  CommonDropDownItem? selectedBrand;
  final List<CommonDropDownItem> brands = [];
  CommonDropDownItem? selectedVideoType;
  final List<CommonDropDownItem> videoType = [];
  final List<FileInfo> productGalleryImages = [];
  FileInfo? thumbnailImage;
  FileInfo? pdfSpecification;
  FileInfo? metaImage;
  //List<String?>? tags = [];
  List<String?> tags = [];
  String? description = "";
  final List<String> itemList = ['new', 'used'];
  String? selectedCondition;

  @override
  void initState() {
    super.initState();
    selectedCondition = itemList.first;
    fetchAll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setConstDropdownValues();
  }

  void setConstDropdownValues() {
    videoType.addAll([
      CommonDropDownItem("youtube", 'youtube_ucf'.tr(context: context)),
      CommonDropDownItem("dailymotion", 'dailymotion_ucf'.tr(context: context)),
      CommonDropDownItem("vimeo", 'vimeo_ucf'.tr(context: context)),
    ]);
    selectedVideoType = videoType.first;
  }

  List<CommonDropDownItemWithChild> setChildCategory(List<CatData> child) {
    final List<CommonDropDownItemWithChild> list = [];
    for (var element in child) {
      final children = element.child ?? [];
      final model = CommonDropDownItemWithChild(
        key: element.id.toString(),
        value: element.name,
        children: children.isNotEmpty ? setChildCategory(children) : [],
      );
      list.add(model);
    }
    return list;
  }

  Future<void> getCategories() async {
    final categoryResponse = await ProductRepository().getCategoryRes();
    for (var element in categoryResponse.data!) {
      final model = CommonDropDownItemWithChild(
        key: element.id.toString(),
        value: element.name,
        level: element.level,
        children: setChildCategory(element.child!),
      );
      categories.add(model);
    }
    if (categories.isNotEmpty) {
      selectedCategory = categories.first;
    }
    setState(() {});
  }

  Future<void> getBrands() async {
    final brandsRes = await BrandRepository().getAllBrands();
    for (var element in brandsRes.data!) {
      brands.add(CommonDropDownItem("${element.id}", element.name));
    }
    setState(() {});
  }

  bool requiredFieldVerification() {
    if (productNameEditTextController.text.trim().isEmpty) {
      ToastComponent.showDialog('product_name_required'.tr(context: context));
      return false;
    } else if (unitEditTextController.text.trim().isEmpty) {
      ToastComponent.showDialog('product_unit_required'.tr(context: context));
      return false;
    } else if (locationTextController.text.trim().isEmpty) {
      ToastComponent.showDialog('location_required'.tr(context: context));
      return false;
    } else if (tags.isEmpty) {
      ToastComponent.showDialog('product_tag_required'.tr(context: context));
      return false;
    } else if (description == "") {
      ToastComponent.showDialog(
          'product_description_required'.tr(context: context));
      return false;
    }
    return true;
  }

  String? productName,
      brandId,
      categoryId,
      unit,
      conditon,
      location,
      photos,
      thumbnailImg,
      videoProvider,
      videoLink,
      unitPrice,
      externalLink,
      pdf,
      metaTitle,
      metaDescription,
      metaImg;

  //List<String> tagMap = [];
  var tagMap = [];

  void setProductPhotoValue() {
    photos = "";
    for (int i = 0; i < productGalleryImages.length; i++) {
      if (i != (productGalleryImages.length - 1)) {
        photos = "$photos ${productGalleryImages[i].id},";
      } else {
        photos = "$photos ${productGalleryImages[i].id}";
      }
    }
  }

  Future<void> setProductValues() async {
    productName = productNameEditTextController.text.trim();
    if (selectedBrand != null) brandId = selectedBrand!.key;
    if (selectedCategory != null) categoryId = selectedCategory!.key;
    unit = unitEditTextController.text.trim();
    conditon = selectedCondition;
    location = locationTextController.text.trim();

    tagMap.clear();
    tags.forEach((element) {
      tagMap.add(jsonEncode({"value": '$element'}));
    });
    // description is up there
    if (productDescriptionKey.currentState != null) {
      description = await productDescriptionKey.currentState!.getText();
    }

    setProductPhotoValue();

    if (thumbnailImage != null) thumbnailImg = "${thumbnailImage!.id}";
    videoProvider = selectedVideoType!.key;
    videoLink = videoLinkController.text.trim();

    if (pdfSpecification != null) pdf = "${pdfSpecification!.id}";
    unitPrice = unitPriceEditTextController.text.trim();
    metaTitle = metaTitleTextController.text.trim();
    metaDescription = metaDescriptionEditTextController.text.trim();
    if (metaImage != null) metaImg = "${metaImage!.id}";
  }

  Future<void> submit() async {
    if (!requiredFieldVerification()) {
      return;
    }
    Loading.show(context);
    await setProductValues();
    final Map<String, dynamic> postValue = {
      "name": productName,
      "added_by": "customer",
      "category_id": categoryId,
      "brand_id": brandId,
      "unit": unit,
      "conditon": selectedCondition,
      "location": location,
      "tags": [tagMap.toString()],
      "description": description,
      "photos": photos,
      "thumbnail_img": thumbnailImg,
      "video_provider": videoProvider,
      "video_link": videoLink,
      "pdf": pdf,
      "unit_price": unitPrice,
      "meta_title": metaTitle,
      "meta_description": metaDescription,
      "meta_img": metaImg,
    };

    final postBody = jsonEncode(postValue);
    final response =
        await ClassifiedProductRepository().addProductResponse(postBody);

    Loading.close();
    if (response.result) {
      ToastComponent.showDialog(response.message);
      Navigator.pop(context);
    } else {
      final dynamic errorMessages = response.message;
      if (errorMessages.runtimeType == String) {
        ToastComponent.showDialog(errorMessages);
      } else {
        ToastComponent.showDialog(errorMessages.join(","));
      }
    }
  }

  void fetchAll() {
    getBrands();
    getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            "add_new_classified_product_ucf".tr(context: context),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: MyTheme.dark_font_grey,
            ),
          ),
          backgroundColor: MyTheme.white,
          leading: UsefulElements.backButton(),
        ),
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Column(
          children: [
            buildGeneral(),
            itemSpacer(),
            buildMedia(),
            itemSpacer(),
            buildPrice(),
          ],
        ),
      ),
    );
  }

  Widget buildGeneral() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _generalExpanded = !_generalExpanded;
        });
      },
      child: Material(
        elevation: 10,
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0),
            borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
            border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0), width: 0.0),
            boxShadow: const [
              BoxShadow(color: MyTheme.white),
            ],
          ),
          padding: const EdgeInsets.only(
              top: AppDimensions.paddingSupSmall, left: 5, right: 5),
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'general_ucf'.tr(context: context),
                    style: const TextStyle(
                      fontSize: 13,
                      color: MyTheme.dark_font_grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    _generalExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.navigate_next_rounded,
                    size: 20,
                    color: MyTheme.dark_font_grey,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Visibility(
                visible: _generalExpanded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildEditTextField(
                      'product_name_ucf'.tr(context: context),
                      'product_name_ucf'.tr(context: context),
                      productNameEditTextController,
                      isMandatory: true,
                    ),
                    itemSpacer(),
                    _buildDropDownField(
                      'brand_ucf'.tr(context: context),
                      (value) {
                        selectedBrand = value;
                        setState(() {});
                      },
                      selectedBrand,
                      brands,
                    ),
                    itemSpacer(),
                    _buildDropDownFieldWithChildren(
                      'categories_ucf'.tr(context: context),
                      (value) {
                        selectedCategory = value;
                        setState(() {});
                      },
                      selectedCategory,
                      categories,
                    ),
                    itemSpacer(),
                    buildEditTextField(
                      'product_unit_ucf'.tr(context: context),
                      'product_unit_ucf'.tr(context: context),
                      unitEditTextController,
                      isMandatory: true,
                    ),
                    itemSpacer(),
                    buildGroupItems(
                      'condition_ucf'.tr(context: context),
                      Focus(
                        onFocusChange: (hasFocus) {
                          setState(() {
                            _hasFocus = hasFocus;
                          });
                        },
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusHalfSmall),
                            color: MyTheme.white,
                            border: Border.all(
                                color: _hasFocus
                                    ? MyTheme.textfield_grey
                                    : Theme.of(context).primaryColor,
                                style: BorderStyle.solid,
                                width: _hasFocus ? 0.5 : 0.2),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    MyTheme.blue_grey.withValues(alpha: 0.15),
                                blurRadius: 20,
                                spreadRadius: 0.0,
                                offset: const Offset(0.0,
                                    10.0), // shadow direction: bottom right
                              )
                            ],
                          ),
                          child: DropdownButton<String>(
                            menuMaxHeight: 300,
                            isDense: true,
                            underline: emptyWidget,
                            isExpanded: true,
                            onChanged: (String? value) {
                              setState(() {
                                selectedCondition = value;
                              });
                            },
                            icon: const Icon(Icons.arrow_drop_down),
                            value: selectedCondition,
                            items: itemList
                                .map(
                                  (value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(
                                          color: MyTheme.font_grey,
                                          fontSize: 12),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    itemSpacer(),
                    buildEditTextField(
                        'location_ucf'.tr(context: context),
                        'location_ucf'.tr(context: context),
                        locationTextController,
                        isMandatory: true),
                    itemSpacer(),
                    buildTagsEditTextField('tags_ucf'.tr(context: context),
                        'tags_ucf'.tr(context: context), tagEditTextController,
                        isMandatory: true),
                    itemSpacer(),
                    buildGroupItems(
                      'descriptions_ucf'.tr(context: context),
                      summerNote('descriptions_ucf'.tr(context: context)),
                    ),
                    itemSpacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector buildMedia() {
    return GestureDetector(
      onTap: () {
        _mediaExpanded = !_mediaExpanded;
        setState(() {});
      },
      child: Material(
        elevation: 10,
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0),
            borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
            border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0), width: 0.0),
            boxShadow: const [
              BoxShadow(
                color: MyTheme.white,
              ),
            ],
          ),
          padding: const EdgeInsets.only(
              top: AppDimensions.paddingSupSmall, left: 5, right: 5),
          alignment: Alignment.topCenter,
          // height: _mediaExpanded ? 200 : 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'media_ucf'.tr(context: context),
                    style: const TextStyle(
                        fontSize: 13,
                        color: MyTheme.dark_font_grey,
                        fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    _mediaExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.navigate_next_rounded,
                    size: 20,
                    color: MyTheme.dark_font_grey,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Visibility(
                visible: _mediaExpanded,
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      chooseGalleryImageField(),
                      itemSpacer(),
                      chooseSingleImageField(
                          'thumbnail_image_ucf'.tr(context: context),
                          (onChosenImage) {
                        thumbnailImage = onChosenImage;
                        setChange();
                      }, thumbnailImage),
                      buildGroupItems(
                          'video_form_ucf'.tr(context: context),
                          _buildDropDownField(
                              'video_url_ucf'.tr(context: context), (newValue) {
                            selectedVideoType = newValue;
                            setChange();
                          }, selectedVideoType, videoType)),
                      itemSpacer(),
                      buildEditTextField(
                        'video_url_ucf'.tr(context: context),
                        'video_link_ucf'.tr(context: context),
                        videoLinkController,
                      ),
                      itemSpacer(),
                      chooseSingleImageField("Pdf Specification",
                          (onChosenImage) {
                        pdfSpecification = onChosenImage;
                        setChange();
                      }, pdfSpecification),
                      chooseSingleFileField(
                          'pdf_specification_ucf'.tr(context: context), "",
                          (onChosenFile) {
                        pdfSpecification = onChosenFile;
                        setChange();
                      }, pdfSpecification),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget chooseSingleFileField(String title, String shortMessage,
      dynamic onChosenFile, FileInfo? selectedFile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 12,
                  color: MyTheme.font_grey,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            fileField(
                'document'.tr(context: context), onChosenFile, selectedFile)
          ],
        ),
      ],
    );
  }

  Widget fileField(
      String fileType, dynamic onChosenFile, FileInfo? selectedFile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () async {
            // XFile chooseFile = await pickSingleImage();
            final List<FileInfo> chooseFile = await (Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UploadFile(
                          fileType: fileType,
                          canSelect: true,
                        ))));
            // print("chooseFile.url");
            // print(chooseFile.first.url);
            if (chooseFile.isNotEmpty) {
              onChosenFile(chooseFile.first);
            }
          },
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusaHalfsmall)),
          child: MyWidget().myContainer(
            width: DeviceInfo(context).width!.toDouble(),
            height: 36,
            borderRadius: 6.0,
            borderColor: MyTheme.light_grey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppDimensions.paddingNormal),
                  child: Text(
                    'choose_file'.tr(context: context),
                    style:
                        const TextStyle(fontSize: 12, color: MyTheme.grey_153),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  height: 46,
                  width: 80,
                  color: MyTheme.light_grey,
                  child: Text(
                    'browse'.tr(context: context),
                    style:
                        const TextStyle(fontSize: 12, color: MyTheme.grey_153),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        if (selectedFile != null)
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                height: 40,
                alignment: Alignment.center,
                width: 40,
                decoration: const BoxDecoration(
                  color: MyTheme.grey_153,
                ),
                child: Text(
                  selectedFile.fileOriginalName! +
                      "." +
                      selectedFile.extension!,
                  style: const TextStyle(fontSize: 9, color: MyTheme.white),
                ),
              ),
              Positioned(
                top: 0,
                right: 5,
                child: Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          AppDimensions.RadiusExtraMedium),
                      color: MyTheme.white),
                  // remove the selected file button
                  child: InkWell(
                    onTap: () {
                      onChosenFile(null);
                    },
                    child: const Icon(
                      Icons.close,
                      size: 12,
                      color: MyTheme.brick_red,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget chooseSingleImageField(
      String title, dynamic onChosenImage, FileInfo? selectedFile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 12,
                  color: MyTheme.font_grey,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            imageField(onChosenImage, selectedFile)
          ],
        ),
      ],
    );
  }

  Widget imageField(dynamic onChosenImage, FileInfo? selectedFile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () async {
            // XFile chooseFile = await pickSingleImage();
            final List<FileInfo> chooseFile = await (Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UploadFile(
                          fileType: "image",
                          canSelect: true,
                        ))));
            // print("chooseFile.url");
            // print(chooseFile.first.url);
            if (chooseFile.isNotEmpty) {
              onChosenImage(chooseFile.first);
            }
          },
          child: MyWidget().myContainer(
            width: DeviceInfo(context).width!,
            height: 36,
            borderColor: Theme.of(context).primaryColor,
            borderWith: 0.2,
            borderRadius: 6.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: AppDimensions.paddingNormal),
                  child: Text(
                    'choose_file'.tr(context: context),
                    style:
                        const TextStyle(fontSize: 12, color: MyTheme.grey_153),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  height: 46,
                  width: 80,
                  color: MyTheme.light_grey,
                  child: Text(
                    'browse'.tr(context: context),
                    style:
                        const TextStyle(fontSize: 12, color: MyTheme.grey_153),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (selectedFile != null)
          Stack(
            fit: StackFit.passthrough,
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.bottomCenter,
            children: [
              const SizedBox(
                height: 60,
                width: 70,
              ),
              MyWidget.imageWithPlaceholder(
                  border: Border.all(width: 0.5, color: MyTheme.light_grey),
                  radius: BorderRadius.circular(AppDimensions.radiusSmallExtra),
                  height: 50.0,
                  width: 50.0,
                  url: selectedFile.url),
              Positioned(
                top: 3,
                right: 2,
                child: Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          AppDimensions.RadiusExtraMedium),
                      color: MyTheme.light_grey),
                  child: InkWell(
                    onTap: () {
                      onChosenImage(null);
                    },
                    child: const Icon(
                      Icons.close,
                      size: 12,
                      color: MyTheme.cinnabar,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  GestureDetector buildPrice() {
    return GestureDetector(
      onTap: () {
        _priceExpanded = !_priceExpanded;
        setState(() {});
      },
      child: Material(
        elevation: 10,
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0),
            borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
            border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0), width: 0.0),
            boxShadow: const [
              BoxShadow(
                color: MyTheme.white,
              ),
            ],
          ),
          padding: const EdgeInsets.only(
              top: AppDimensions.paddingSupSmall, left: 5, right: 5),
          alignment: Alignment.topCenter,
          // height: _priceExpanded ? 200 : 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'auction_price_ucf'.tr(context: context),
                    style: const TextStyle(
                        fontSize: 13,
                        color: MyTheme.dark_font_grey,
                        fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    _priceExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.navigate_next_rounded,
                    size: 20,
                    color: MyTheme.dark_font_grey,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Visibility(
                visible: _priceExpanded,
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildEditTextField(
                        'auction_price_ucf'.tr(context: context),
                        'custom_unit_price_and_base_price'.tr(context: context),
                        unitPriceEditTextController,
                        isMandatory: true,
                      ),
                      itemSpacer(),
                      buildGroupItems(
                        'meta_tags_ucf'.tr(context: context),
                        buildEditTextField(
                          'meta_title_ucf'.tr(context: context),
                          'meta_title_ucf'.tr(context: context),
                          metaTitleTextController,
                          isMandatory: false,
                        ),
                      ),
                      itemSpacer(),
                      buildGroupItems(
                        'meta_description_ucf'.tr(context: context),
                        Container(
                          padding: const EdgeInsets.all(8),
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusHalfSmall),
                            border: Border.all(
                                color: Theme.of(context).primaryColor,
                                style: BorderStyle.solid,
                                width: 0.1),
                            boxShadow: [
                              BoxShadow(
                                color: MyTheme.white.withValues(alpha: 0.15),
                                blurRadius: 20,
                                spreadRadius: 0.0,
                                offset: const Offset(0.0,
                                    10.0), // shadow direction: bottom right
                              )
                            ],
                          ),
                          child: TextField(
                            controller: metaDescriptionEditTextController,
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            maxLines: 50,
                            enabled: true,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration.collapsed(
                                hintText: 'meta_description_ucf'
                                    .tr(context: context)),
                          ),
                        ),
                      ),
                      itemSpacer(),
                      chooseSingleImageField(
                          'meta_image_ucf'.tr(context: context),
                          (onChosenImage) {
                        metaImage = onChosenImage;
                        setChange();
                      }, metaImage),

                      // submit button
                      itemSpacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  Theme.of(context).primaryColor),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusHalfSmall),
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                            ),
                            onPressed: submit,
                            child: Text(
                              'save_product_ucf'.tr(context: context),
                              style: const TextStyle(color: Colors.white),
                            )),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEditTextField(
      String title, String hint, TextEditingController textEditingController,
      {isMandatory = false}) {
    return Container(
      child: buildCommonSingleField(
        title,
        MyWidget.customCardView(
          shadowColor: MyTheme.noColor,
          backgroundColor: MyTheme.white,
          elevation: 0,
          width: DeviceInfo(context).width!,
          height: 36,
          borderRadius: 10,
          child: TextField(
            controller: textEditingController,
            decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: MyTheme.white,
                hintStyle: const TextStyle(
                    fontSize: 12.0, color: MyTheme.textfield_grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 0.2),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppDimensions.radiusHalfSmall),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide:
                      BorderSide(color: MyTheme.textfield_grey, width: 0.5),
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppDimensions.radiusHalfSmall),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0)),
          ),
        ),
        isMandatory: isMandatory,
      ),
    );
  }

  Column buildCommonSingleField(title, Widget child, {isMandatory = false}) {
    return Column(
      children: [
        Row(
          children: [
            buildFieldTitle(title),
            if (isMandatory)
              const Text(
                " *",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        child,
      ],
    );
  }

  Text buildFieldTitle(title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.bold, color: MyTheme.font_grey),
    );
  }

  Widget itemSpacer({double height = 10}) {
    return SizedBox(
      height: height,
    );
  }

  Widget _buildDropDownField(
    String title,
    dynamic onchange,
    CommonDropDownItem? selectedValue,
    List<CommonDropDownItem> itemList, {
    bool isMandatory = false,
    double? width,
  }) {
    return buildCommonSingleField(
        title, _buildDropDown(onchange, selectedValue, itemList, width: width),
        isMandatory: isMandatory);
  }

  Widget _buildDropDownFieldWithChildren(
    String title,
    dynamic onchange,
    CommonDropDownItemWithChild? selectedValue,
    List<CommonDropDownItemWithChild> itemList, {
    bool isMandatory = false,
    double? width,
  }) {
    return buildCommonSingleField(
        title,
        _buildDropDownWithChildren(onchange, selectedValue, itemList,
            width: width),
        isMandatory: isMandatory);
  }

  Widget _buildDropDown(
    dynamic onchange,
    CommonDropDownItem? selectedValue,
    List<CommonDropDownItem> itemList, {
    double? width,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {},
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
          border: Border.all(
              color: Theme.of(context).primaryColor,
              style: BorderStyle.solid,
              width: 0.2),
          boxShadow: const [],
        ),
        child: DropdownButton<CommonDropDownItem>(
          borderRadius: BorderRadius.circular(AppDimensions.radiusNormal),
          dropdownColor: Colors.white,
          menuMaxHeight: 300,
          isDense: true,
          underline: emptyWidget,
          isExpanded: true,
          onChanged: (CommonDropDownItem? value) {
            onchange(value);
          },
          icon: const Icon(
            Icons.arrow_drop_down,
            size: 22,
          ),
          value: selectedValue,
          items: itemList
              .map(
                (value) => DropdownMenuItem<CommonDropDownItem>(
                  value: value,
                  child: Text(
                    value.value!,
                    style: const TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildDropDownWithChildren(
    dynamic onchange,
    CommonDropDownItemWithChild? selectedValue,
    List<CommonDropDownItemWithChild> itemList, {
    double? width,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {},
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
          border: Border.all(
              color: Theme.of(context).primaryColor,
              style: BorderStyle.solid,
              width: 0.2),
          boxShadow: [
            BoxShadow(
              color: MyTheme.white.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: 0.0,
              offset: const Offset(0.0, 10.0), // shadow direction: bottom right
            )
          ],
        ),
        child: DropdownButton<CommonDropDownItemWithChild>(
          menuMaxHeight: 300,
          isDense: true,
          underline: emptyWidget,
          isExpanded: true,
          onChanged: (CommonDropDownItemWithChild? value) {
            onchange(value);
          },
          icon: const Icon(Icons.arrow_drop_down),
          value: selectedValue,
          items: itemList
              .map(
                (value) => DropdownMenuItem<CommonDropDownItemWithChild>(
                  value: value,
                  child: Text(
                    value.value!,
                    style: const TextStyle(
                        color: MyTheme.font_grey, fontSize: 12.0),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void setChange() {
    setState(() {});
  }

  Widget buildTagsEditTextField(
      String title, String hint, TextEditingController textEditingController,
      {isMandatory = false}) {
    return buildCommonSingleField(
      title,
      Container(
        padding: const EdgeInsets.only(
            top: AppDimensions.paddingSupSmall,
            bottom: 8,
            left: AppDimensions.paddingSupSmall,
            right: AppDimensions.paddingSupSmall),
        alignment: Alignment.centerLeft,
        constraints: BoxConstraints(minWidth: DeviceInfo(context).width!),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
          // color: MyTheme.light_grey,
          border: Border.all(
              color: Theme.of(context).primaryColor,
              style: BorderStyle.solid,
              width: 0.2),
          boxShadow: [
            BoxShadow(
              color: MyTheme.white.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: 0.0,
              offset: const Offset(0.0, 10.0), // shadow direction: bottom right
            )
          ],
        ),
        child: Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          runAlignment: WrapAlignment.start,
          clipBehavior: Clip.antiAlias,
          children: List.generate(tags.length + 1, (index) {
            if (index == tags.length) {
              return TextField(
                onSubmitted: (string) {
                  final tag = textEditingController.text
                      .trim()
                      .replaceAll(",", "")
                      .toString();
                  if (tag.isNotEmpty) addTag(tag);
                },
                onChanged: (string) {
                  if (string.trim().contains(",")) {
                    final tag = string.trim().replaceAll(",", "").toString();
                    if (tag.isNotEmpty) addTag(tag);
                  }
                },
                controller: textEditingController,
                keyboardType: TextInputType.text,
                maxLines: 1,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration.collapsed(
                  hintText: 'type_and_hit_submit_ucf'.tr(context: context),
                  hintStyle: const TextStyle(fontSize: 12),
                ).copyWith(
                  constraints: const BoxConstraints(maxWidth: 150),
                ),
              );
            }
            return Container(
                decoration: BoxDecoration(
                    color: MyTheme.white,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSmallExtra),
                    border: Border.all(width: 2, color: MyTheme.grey_153)),
                constraints: BoxConstraints(
                    maxWidth: (DeviceInfo(context).width! - 50) / 4),
                margin: const EdgeInsets.only(right: 5, bottom: 5),
                child: Stack(
                  fit: StackFit.loose,
                  children: [
                    Container(
                        padding: const EdgeInsets.only(
                            left: 10, right: 20, top: 5, bottom: 5),
                        constraints: BoxConstraints(
                            maxWidth: (DeviceInfo(context).width! - 50) / 4),
                        child: Text(
                          tags[index].toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        )),
                    Positioned(
                      right: 2,
                      child: InkWell(
                        onTap: () {
                          tags.removeAt(index);
                          setChange();
                        },
                        child: const Icon(Icons.highlight_remove,
                            size: 15, color: MyTheme.cinnabar),
                      ),
                    )
                  ],
                ));
          }),
        ),
      ),
      isMandatory: isMandatory,
    );
  }

  void addTag(String string) {
    if (string.trim().isNotEmpty) {
      tags.add(string.trim());
    }
    tagEditTextController.clear();
    setChange();
  }

  Widget buildGroupItems(groupTitle, Widget children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildGroupTitle(groupTitle),
        itemSpacer(height: 14.0),
        children,
      ],
    );
  }

  Text buildGroupTitle(title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.bold, color: MyTheme.font_grey),
    );
  }

  Column summerNote(title) {
    if (productDescriptionKey.currentState != null) {
      productDescriptionKey.currentState!.getText().then((value) {
        description = value;
        print(description);
        if (description != null) {
          // productDescriptionKey.currentState.setText(description);
        }
      });
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: MyTheme.font_grey),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          height: 220,
          width: double.infinity,
          child: FlutterSummernote(
              showBottomToolbar: false,
              value: description,
              key: productDescriptionKey),
        ),
      ],
    );
  }

  Future<void> pickGalleryImages() async {
    final tmp = productGalleryImages;
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UploadFile(
                  fileType: "image",
                  canSelect: true,
                  canMultiSelect: true,
                  prevData: tmp,
                )));
    // print(images != null);
    //  productGalleryImages = images;
    setChange();
  }

  Widget chooseGalleryImageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'gallery_images'.tr(context: context),
              style: const TextStyle(
                  fontSize: 12,
                  color: MyTheme.font_grey,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
              // padding: EdgeInsets.zero,
              onPressed: () {
                pickGalleryImages();
              },
              // shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(AppDimensions.radiusaHalfsmall)),
              child: MyWidget().myContainer(
                  width: DeviceInfo(context).width!,
                  height: 36,
                  borderRadius: 6.0,
                  borderColor: Theme.of(context).primaryColor,
                  borderWith: 0.2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: AppDimensions.paddingNormal),
                        child: Text(
                          'choose_file'.tr(context: context),
                          style: const TextStyle(
                              fontSize: 12, color: MyTheme.grey_153),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        height: 46,
                        width: 80,
                        color: MyTheme.light_grey,
                        child: Text(
                          'browse'.tr(context: context),
                          style: const TextStyle(
                              fontSize: 12, color: MyTheme.grey_153),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        if (productGalleryImages.isNotEmpty)
          Wrap(
            children: List.generate(
              productGalleryImages.length,
              (index) => Stack(
                children: [
                  MyWidget.imageWithPlaceholder(
                      height: 60.0,
                      width: 60.0,
                      url: productGalleryImages[index].url),
                  Positioned(
                    top: 0,
                    right: 5,
                    child: Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.RadiusExtraMedium),
                          color: MyTheme.white),
                      child: InkWell(
                        onTap: () {
                          print(index);
                          productGalleryImages.removeAt(index);
                          setState(() {});
                        },
                        child: const Icon(
                          Icons.close,
                          size: 12,
                          color: MyTheme.cinnabar,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class CommonDropDownItem {
  String? key, value;

  CommonDropDownItem(this.key, this.value);
}

class CommonDropDownItemWithChild {
  String? key, value, levelText;
  int? level;
  List<CommonDropDownItemWithChild> children;

  CommonDropDownItemWithChild(
      {this.key,
      this.value,
      this.levelText,
      this.children = const [],
      this.level});

  void setLevelText() {
    String tmpTxt = "";
    for (int i = 0; i < level!; i++) {
      tmpTxt += "–";
    }
    levelText = "$tmpTxt $levelText";
  }
}
