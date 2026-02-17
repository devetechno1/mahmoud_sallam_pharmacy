import 'package:active_ecommerce_cms_demo_app/helpers/main_helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

import '../../helpers/download/download_paths.dart';
import '../../helpers/download/download_service.dart';
import '../../providers/download_provider.dart';

// NOTE: Keep using your existing AppDimensions/AppImages as in your project.

class PurchasedDigitalProductCard extends StatefulWidget
    with WidgetsBindingObserver {
  final int? id;
  final String? image;
  final String? name;

  const PurchasedDigitalProductCard(
      {super.key, this.id, this.image, this.name});

  @override
  State<PurchasedDigitalProductCard> createState() =>
      _PurchasedDigitalProductCardState();
}

class _PurchasedDigitalProductCardState
    extends State<PurchasedDigitalProductCard> {
  DownloadProvider? _provider;

  @override
  void initState() {
    super.initState();
    _initProvider();
  }

  Future<void> _initProvider() async {
    final base = await DownloadPaths.appBaseForDownload();
    final task = DownloadTask(
      uri: Uri.parse(
        '${AppConfig.BASE_URL}/purchased-products/download/${widget.id}',
      ),
      baseDir: base,
      headers: commonHeader,
    );
    setState(() {
      _provider = DownloadProvider(task);
    });
  }

  @override
  void dispose() {
    _provider?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = _provider;
    if (p == null) return const SizedBox.shrink();

    return ChangeNotifierProvider.value(
      value: p,
      child: Consumer<DownloadProvider>(
        builder: (context, d, _) {
          final isDownloading = d.status == DownloadStatus.running ||
              d.status == DownloadStatus.paused;
          final isDone = d.status == DownloadStatus.completed;
          final percent = d.percent;

          return Column(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusNormal),
                  child: FadeInImage.assetNetwork(
                    placeholder: AppImages.placeholder,
                    image: widget.image ?? AppImages.placeholder,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                child: Text(
                  widget.name ?? 'no_name'.tr(context: context),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Color(0xff6B7377),
                    fontSize: 12,
                    height: 1.2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              if (isDownloading) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: percent, // null -> indeterminate
                    minHeight: 8,
                    backgroundColor: const Color(0xFFEAEAEA),
                  ),
                ),
                if (percent != null ||
                    d.speedBytesPerSec != null ||
                    d.eta != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (percent != null)
                        Text(
                          '${((percent * 100).clamp(0, 100)).toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 12),
                        ),
                      if (d.speedBytesPerSec != null)
                        Text(_humanSpeed(d.speedBytesPerSec!),
                            style: const TextStyle(fontSize: 12)),
                      if (d.eta != null)
                        Text('ETA ${_fmtEta(d.eta!)}',
                            style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ],

              // Primary button (old style)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: InkWell(
                  onTap: () async {
                    if (isDone) return; // already downloaded
                    if (d.status == DownloadStatus.idle ||
                        d.status == DownloadStatus.canceled ||
                        d.status == DownloadStatus.failed) {
                      await d.start();
                    } else if (d.status == DownloadStatus.running) {
                      d.pause();
                    } else if (d.status == DownloadStatus.paused) {
                      await d.resume();
                    }
                  },
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSmallExtra),
                  child: Container(
                    height: 24,
                    width: 170,
                    decoration: BoxDecoration(
                      color: isDone
                          ? const Color(0xFF9E9E9E)
                          : const Color(0xffE5411C),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSmallExtra),
                    ),
                    child: Center(
                      child: Text(
                        isDone
                            ? 'downloaded'.tr(context: context) // "Downloaded"
                            : (d.status == DownloadStatus.paused
                                ? 'resume'.tr(context: context) // "Resume"
                                : d.status == DownloadStatus.running
                                    ? 'pause'.tr(context: context) // "Pause"
                                    : 'download'
                                        .tr(context: context) // "Download"
                            ),
                        style: const TextStyle(
                          fontFamily: 'Public Sans',
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          height: 1.8,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Secondary cancel button (visible only while downloading/paused)
              if (isDownloading)
                TextButton(
                  onPressed: () => d.cancel(),
                  child: Text('cancel'.tr(context: context)),
                ),

              // Optional: show final file name after completion
              if (isDone && d.fileName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    d.fileName!,
                    style:
                        const TextStyle(fontSize: 11, color: Color(0xff6B7377)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _humanSpeed(double bps) {
    const kb = 1024;
    const mb = 1024 * 1024;
    if (bps >= mb) return '${(bps / mb).toStringAsFixed(1)} MB/s';
    if (bps >= kb) return '${(bps / kb).toStringAsFixed(1)} KB/s';
    return '${bps.toStringAsFixed(0)} B/s';
  }

  String _fmtEta(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds % 60}s';
    return '${d.inSeconds}s';
  }
}
