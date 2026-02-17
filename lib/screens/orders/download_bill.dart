import 'dart:async';
import 'dart:io';
import 'package:active_ecommerce_cms_demo_app/helpers/main_helpers.dart';
import 'package:flutter/material.dart';

// your app imports
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/btn.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../helpers/download/download_paths.dart';
import '../../helpers/download/download_service.dart';
import '../../helpers/download/media_store_saver.dart';
import '../../main.dart';
import '../../my_theme.dart';

class DownloadBill extends StatefulWidget {
  const DownloadBill({super.key, required this.orderId});
  final int orderId;

  @override
  State<DownloadBill> createState() => _DownloadBillState();
}

class _DownloadBillState extends State<DownloadBill> {
  // Simple UI state: idle -> loading -> done/error
  bool _isLoading = false;
  bool _isDone = false;
  StreamSubscription<DownloadProgress>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _downloadInvoice(int id) async {
    if (_isLoading || _isDone) return;

    setState(() => _isLoading = true);

    try {
      // Use a temp/documents base (Android = cache, iOS = documents).
      final baseDir = await DownloadPaths.appBaseForDownload();

      // Build task for the invoice endpoint.
      final task = DownloadTask(
        uri: Uri.parse('${AppConfig.BASE_URL}/invoice/download/$id'),
        baseDir: baseDir,
        headers: commonHeader,
      );

      // Start stream (we don't need progress here, just the final result).
      final c = Completer<void>();
      _sub = task.start(onDone: (result) async {
        switch (result.status) {
          case DownloadStatus.completed:
            // Export to Public Downloads on Android and delete temp immediately (move semantics)
            if (Platform.isAndroid && result.file != null) {
              try {
                await MediaStoreSaver.saveToPublicDownloads(
                  filePath: result.file!.path,
                  fileName: result.fileName ?? 'invoice_$id.pdf',
                  mimeType: result.mimeType ?? 'application/pdf',
                  subDir: AppConfig.appNameOnDeviceLang,
                );
                try {
                  await result.file!.delete();
                } catch (_) {}
              } catch (_) {
                // Keep local temp if export fails; user still has the file privately
              }
            }
            // Toast success (same style)
            ToastComponent.showDialog(
              'file_download_success'.tr(context: context),
              color: const Color(0xFF4CAF50),
              gravity: ToastGravity.BOTTOM,
            );
            setState(() {
              _isDone = true;
            });
            c.complete();
            break;

          case DownloadStatus.failed:
            ToastComponent.showDialog('download_failed'.tr(context: context),
                isError: true);
            c.complete();
            break;

          case DownloadStatus.canceled:
            // No user cancel in this button, but just in case
            c.complete();
            break;

          default:
            c.complete();
        }
      }).listen((_) {
        // No-op: we don't show percentage here, only a spinner.
      });

      await c.future;
    } catch (e, st) {
      // Record backend errors (no user cancel here)
      recordError(e, st);
      ToastComponent.showDialog('download_failed'.tr(context: context),
          isError: true);
    } finally {
      await _sub?.cancel();
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = _isLoading || _isDone;

    return Btn.basic(
      minWidth: 60,
      isLoading: isDisabled,
      disabledBackgroundColor: Colors.transparent,
      onPressed: isDisabled ? null : () => _downloadInvoice(widget.orderId),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingNormal,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          border: Border.all(color: MyTheme.medium_grey),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show spinner while loading, otherwise the download icon
            if (_isLoading)
              const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(
                Icons.file_download_outlined,
                color: MyTheme.grey_153,
                size: 16,
              ),
            const SizedBox(width: 6),
            Text(
              _isDone
                  ? 'invoice_downloaded'
                      .tr(context: context) // "تم تحميل الفاتورة"
                  : 'invoice_ucf'
                      .tr(context: context), // your existing key for "Invoice"
              style: const TextStyle(
                color: MyTheme.grey_153,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
