import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/download/download_service.dart';
import '../providers/download_provider.dart';

class AdaptiveDownloadTile extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onOpen; // how to open file after completed

  const AdaptiveDownloadTile({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DownloadProvider>();
    final percent = p.percent;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: kElevationToShadow[1],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent, // null -> indeterminate
              minHeight: 8,
              backgroundColor: Theme.of(context).dividerColor.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 8),
          _infoRow(context, p),
          const SizedBox(height: 8),
          _controls(context, p),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, DownloadProvider p) {
    String pct = p.percent == null
        ? '…'
        : '${((p.percent! * 100).clamp(0, 100)).toStringAsFixed(0)}%';
    String speed = p.speedBytesPerSec == null ? '' : _humanSpeed(p.speedBytesPerSec!);
    String eta = p.eta == null ? '' : _fmtEta(p.eta!);

    final textStyle = Theme.of(context).textTheme.labelMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(pct, style: textStyle),
        if (speed.isNotEmpty) Text(speed, style: textStyle),
        if (eta.isNotEmpty) Text('ETA $eta', style: textStyle),
      ],
    );
  }

  Widget _controls(BuildContext context, DownloadProvider p) {
    switch (p.status) {
      case DownloadStatus.idle:
        return _primaryButton(context, 'Download', () => p.start());
      case DownloadStatus.running:
        return Row(
          children: [
            Expanded(child: _secondaryButton(context, 'Pause', () => p.pause())),
            const SizedBox(width: 8),
            Expanded(child: _dangerButton(context, 'Cancel', () => p.cancel())),
          ],
        );
      case DownloadStatus.paused:
        return Row(
          children: [
            Expanded(child: _primaryButton(context, 'Resume', () => p.resume())),
            const SizedBox(width: 8),
            Expanded(child: _dangerButton(context, 'Cancel', () => p.cancel())),
          ],
        );
      case DownloadStatus.completed:
        return _primaryButton(context, 'Open', onOpen);
      case DownloadStatus.canceled:
        return _primaryButton(context, 'Download', () => p.start());
      case DownloadStatus.failed:
        return Row(
          children: [
            Expanded(child: _secondaryButton(context, 'Retry', () => p.start())),
            const SizedBox(width: 8),
            Expanded(child: _dangerButton(context, 'Cancel', () => p.cancel())),
          ],
        );
    }
  }

  Widget _primaryButton(BuildContext context, String label, VoidCallback onTap) {
    if (Platform.isIOS) {
      return CupertinoButton.filled(
        padding: const EdgeInsets.symmetric(vertical: 10),
        onPressed: onTap,
        child: Text(label),
      );
    }
    return ElevatedButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(label),
      ),
    );
  }

  Widget _secondaryButton(BuildContext context, String label, VoidCallback onTap) {
    if (Platform.isIOS) {
      return CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 10),
        onPressed: onTap,
        child: Text(label),
      );
    }
    return OutlinedButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(label),
      ),
    );
  }

  Widget _dangerButton(BuildContext context, String label, VoidCallback onTap) {
    if (Platform.isIOS) {
      return CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: CupertinoColors.systemRed,
        onPressed: onTap,
        child: Text(label),
      );
    }
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(label),
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
