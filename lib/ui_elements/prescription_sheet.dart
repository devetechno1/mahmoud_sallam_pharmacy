import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

import '../constants/app_dimensions.dart';
import '../my_theme.dart';
import '../presenter/prescription_controller.dart';

class PrescriptionSheet extends StatelessWidget {
  const PrescriptionSheet({
    super.key,
    required this.controller,
    required this.onAddMore,
    required this.onReplaceAt,
    required this.onDeleteAt,
    required this.onClearAll,
    required this.onSubmit,
    required this.onOpenViewer,
  });

  final PrescriptionController controller;
  final Future<void> Function() onAddMore;
  final Future<void> Function(int index) onReplaceAt;
  final void Function(int index) onDeleteAt;
  final Future<void> Function() onClearAll;
  final Future<void> Function() onSubmit;
  final void Function(int index) onOpenViewer;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cols = PrescriptionUi.columnsForWidth(width);

    return Padding(
      padding: PrescriptionUi.pagePadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'prescription_images'.tr(context: context),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Row(children: [
            ValueListenableBuilder<bool>(
              valueListenable: controller.isUploadingVN,
              builder: (_, uploading, __) => TextButton.icon(
                onPressed: uploading ? null : onAddMore,
                icon: const Icon(Icons.add),
                label: Text('add_more'.tr(context: context)),
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<bool>(
              valueListenable: controller.isUploadingVN,
              builder: (_, uploading, __) => TextButton.icon(
                onPressed: uploading ? null : onClearAll,
                icon: const Icon(Icons.delete_outline),
                label: Text('clear_all_close'.tr(context: context)),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints:
                const BoxConstraints(maxHeight: PrescriptionUi.gridMaxHeight),
            child: ValueListenableBuilder<List<XFile>>(
              valueListenable: controller.imagesVN,
              builder: (_, images, __) {
                if (images.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text('no_images_yet'.tr(context: context)),
                    ),
                  );
                }
                return GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(PrescriptionUi.gridSpacing),
                  itemCount: images.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: PrescriptionUi.gridSpacing,
                    mainAxisSpacing: PrescriptionUi.gridSpacing,
                  ),
                  itemBuilder: (context, i) {
                    final x = images[i];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(children: [
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () => onOpenViewer(i),
                            child: Hero(
                              tag: "${x.path}",
                              transitionOnUserGestures: true,
                              child: Material(
                                type: MaterialType.transparency,
                                child: Image.file(
                                  File(x.path),
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.low,
                                  gaplessPlayback: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                        PositionedDirectional(
                          top: 4,
                          end: 4,
                          child: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'replace') {
                                onReplaceAt(i);
                              } else if (v == 'delete') {
                                onDeleteAt(i);
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'replace',
                                child: Text('replace'.tr(context: context)),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('delete'.tr(context: context)),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<bool>(
            valueListenable: controller.isUploadingVN,
            builder: (_, uploading, __) {
              if (!uploading) return const SizedBox.shrink();
              return Column(children: [
                ValueListenableBuilder<double>(
                  valueListenable: controller.progressVN,
                  builder: (_, p, __) => LinearProgressIndicator(
                    value: p.clamp(0, 1),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<double>(
                  valueListenable: controller.progressVN,
                  builder: (_, p, __) =>
                      Text('${(p * 100).toStringAsFixed(2)}%'),
                ),
                const SizedBox(height: 8),
              ]);
            },
          ),
          SizedBox(
            width: double.infinity,
            child: ValueListenableBuilder<List<XFile>>(
              valueListenable: controller.imagesVN,
              builder: (_, images, __) => ValueListenableBuilder<bool>(
                valueListenable: controller.isUploadingVN,
                builder: (_, uploading, __) => ElevatedButton.icon(
                  onPressed: images.isEmpty || uploading ? null : onSubmit,
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: Text('add_to_cart_ucf'.tr(context: context)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    fixedSize: const Size.fromHeight(60),
                    shadowColor: MyTheme.accent_color_shadow,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusHalfSmall),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper: اعرض الـ BottomSheet ده من أي شاشة
Future<void> showPrescriptionSheetReusable({
  required BuildContext context,
  required PrescriptionController imagesController,
  required Future<void> Function() onAddMore,
  required Future<void> Function(int index) onReplaceAt,
  required void Function(int index) onDeleteAt,
  required Future<void> Function() onClearAll,
  required Future<void> Function() onSubmit,
  required void Function(int index) onOpenViewer,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    clipBehavior: Clip.hardEdge,
    builder: (_) => PrescriptionSheet(
      controller: imagesController,
      onAddMore: onAddMore,
      onReplaceAt: onReplaceAt,
      onDeleteAt: onDeleteAt,
      onClearAll: onClearAll,
      onSubmit: onSubmit,
      onOpenViewer: onOpenViewer,
    ),
  );
}

class PrescriptionUi {
  static const double gridMaxHeight = 420;
  static const double gridSpacing = 8;
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(16, 16, 16, 24);

  static int columnsForWidth(double width) {
    if (width >= 900) return 4;
    if (width >= 600) return 3;
    return 2;
  }
}
