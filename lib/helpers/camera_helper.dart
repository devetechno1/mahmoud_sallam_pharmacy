library flutter_summernote;

import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

abstract final class CameraHelper {
  static final ImagePicker instance = ImagePicker();

  static Future<XFile?> getImage(bool fromCamera) async {
    final picked = await instance.pickImage(
      source: (fromCamera) ? ImageSource.camera : ImageSource.gallery,
    );
    if (picked != null) {
      return XFile(picked.path);
    } else {
      return null;
    }
  }

  // Non-breaking addition: pick multiple images from gallery.
  static Future<List<XFile>> pickMulti() async {
    final List<XFile> picks = await instance.pickMultiImage();
    return picks;
  }

  static Future<XFile?> getImageBottomSheet(
    BuildContext context, {
    String? cameraTitle,
    String? galleryTitle,
  }) async {
    final bool? src = await showModalBottomSheet<bool>(
      context: context,
      clipBehavior: Clip.hardEdge,
      builder: (mctx) => SafeArea(
        bottom: true,
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(cameraTitle ?? "camera".tr(context: mctx)),
            onTap: () => Navigator.pop(mctx, true),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(galleryTitle ?? "gallery".tr(context: mctx)),
            onTap: () => Navigator.pop(mctx, false),
          ),
        ]),
      ),
    );
    if (src == null) return null;
    return await getImage(src);
  }

  static Future<void> openImageSourceSheet(
    BuildContext context, {
    required void Function(List<XFile>) onAddImages,
  }) async {
    if (!context.mounted) return;
    final bool? src = await showModalBottomSheet(
      context: context,
      clipBehavior: Clip.hardEdge,
      builder: (ctx) => SafeArea(
        bottom: true,
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text('camera'.tr(context: context)),
              onTap: () => Navigator.pop(ctx, true),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text('gallery'.tr(context: context)),
              onTap: () => Navigator.pop(ctx, false),
            ),
          ],
        ),
      ),
    );

    if (src == null) return;
    final List<XFile> picks = [];
    if (src) {
      final x = await getImage(true);
      if (x != null) picks.add(x);
    } else {
      picks.addAll(await pickMulti());
    }
    if (picks.isNotEmpty) onAddImages(picks);
  }
}
