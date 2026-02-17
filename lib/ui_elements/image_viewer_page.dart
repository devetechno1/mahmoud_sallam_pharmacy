import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:one_context/one_context.dart';

import '../data_model/cart_response.dart';

/// عارض صور عام:
/// - يقبل أي ImageProvider (FileImage, NetworkImage, AssetImage, CachedNetworkImageProvider).
/// - يدعم Hero (اختياري) مع tags مخصّصة أو تلقائية.
/// - Double-tap zoom حوالين نقطة اللمس.
/// - سحب لفوق للإغلاق (لما مفيش زووم).
/// - وقت الزووم: مفيش تنقّل صفحات (PageView بيتقفل).
class ImageViewerPage extends StatefulWidget {
  const ImageViewerPage({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.heroTags,
    this.enableHero = true,
  });

  /// استخدم أي ImageProvider:
  /// FileImage(File(path)), NetworkImage(url), AssetImage(path),
  /// CachedNetworkImageProvider(url), إلخ.
  final List<ImageProvider> images;

  /// Tags اختيارية للـ Hero. لازم نفس طول الصور لو اتبعتت.
  /// لو null و enableHero=true، هنعمل tags تلقائية ثابتة.
  final List<Object?>? heroTags;

  /// تفعيل/إلغاء الـ Hero
  final bool enableHero;

  final int initialIndex;

  /// مساعد: لو معاك XFile(s) من image_picker.
  factory ImageViewerPage.fromFiles(
    List<XFile> files, {
    int initialIndex = 0,
    List<Object?>? heroTags,
    bool enableHero = true,
  }) {
    return ImageViewerPage(
      images: files.map((f) => FileImage(File(f.path))).toList(),
      initialIndex: initialIndex,
      heroTags: heroTags,
      enableHero: enableHero,
    );
  }

  factory ImageViewerPage.fromNetwork(
    List<String> links, {
    int initialIndex = 0,
    List<Object?>? heroTags,
    bool enableHero = true,
  }) {
    return ImageViewerPage(
      images: links.map((f) => CachedNetworkImageProvider(f)).toList(),
      initialIndex: initialIndex,
      heroTags: heroTags,
      enableHero: enableHero,
    );
  }
  factory ImageViewerPage.prescription(
    List<PrescriptionImages> images, {
    int initialIndex = 0,
    List<Object?>? heroTags,
    bool enableHero = true,
  }) {
    return ImageViewerPage(
      images: images.map((f) => CachedNetworkImageProvider(f.image)).toList(),
      initialIndex: initialIndex,
      heroTags: heroTags,
      enableHero: enableHero,
    );
  }

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage>
    with SingleTickerProviderStateMixin {
  // Page
  late final PageController _pageController =
      PageController(initialPage: widget.initialIndex);
  int _index = 0;

  // Zoom constants
  static const double _minScale = 1.0;
  static const double _maxScale = 4.0;
  static const double _doubleTapScale = 2.5;
  static const Duration _animDuration = Duration(milliseconds: 220);

  // Drag-to-dismiss (فوق فقط)
  static const double _dismissThreshold = 150.0;
  static const double _maxDragForOpacity = 300.0;

  // State
  late final TransformationController _transformCtrl;
  late final AnimationController _animCtrl;
  Animation<Matrix4>? _zoomAnim;
  Offset _doubleTapLocal = Offset.zero;
  bool _zoomedFlag = false;
  double _dragDy = 0.0;

  double get _bgOpacity {
    final p = (1.0 - (_dragDy.abs() / _maxDragForOpacity)).clamp(0.3, 1.0);
    return p;
  }

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;

    _transformCtrl = TransformationController()
      ..addListener(_onTransformChanged);

    _animCtrl = AnimationController(vsync: this, duration: _animDuration)
      ..addListener(() {
        if (_zoomAnim != null) {
          _transformCtrl.value = _zoomAnim!.value;
        }
      });
  }

  @override
  void dispose() {
    _transformCtrl.removeListener(_onTransformChanged);
    _animCtrl.dispose();
    _transformCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final nowZoomed =
        (_transformCtrl.value.getMaxScaleOnAxis() - 1.0).abs() > 0.01;
    if (nowZoomed != _zoomedFlag) {
      setState(() {
        _zoomedFlag = nowZoomed;
      });
    }
  }

  void _animateTo(Matrix4 target) {
    _zoomAnim = Matrix4Tween(
      begin: _transformCtrl.value.clone(),
      end: target,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl
      ..reset()
      ..forward();
  }

  /// Double-tap يزوّم حوالين نقطة اللمس:
  /// T(center) * S(scale) * T(-tap)
  void _onDoubleTap(Size size) {
    if (_zoomedFlag) {
      _animateTo(Matrix4.identity());
      return;
    }
    final targetScale = _doubleTapScale.clamp(_minScale, _maxScale);
    final m = Matrix4.identity()
      ..translate(size.width / 2, size.height / 2)
      ..scale(targetScale)
      ..translate(-_doubleTapLocal.dx, -_doubleTapLocal.dy);
    _animateTo(m);
  }

  void _resetZoomAndDrag() {
    _transformCtrl.value = Matrix4.identity();
    _dragDy = 0.0;
  }

  void _onVerticalDragUpdate(DragUpdateDetails d) {
    setState(() {
      _dragDy += d.delta.dy;
    });
  }

  void _onVerticalDragEnd(DragEndDetails d) {
    final velocityY = d.primaryVelocity ?? 0.0;
    final shouldDismiss =
        (_dragDy <= -_dismissThreshold) || (velocityY < 1000);
    if (shouldDismiss) {
      Navigator.pop(OneContext().context!);
    } else {
      final back = Tween<double>(begin: _dragDy, end: 0.0).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut),
      );
      void tick() => setState(() => _dragDy = back.value);
      _animCtrl
        ..removeListener(tick)
        ..addListener(tick)
        ..reset()
        ..forward().whenComplete(() => _animCtrl.removeListener(tick));
    }
  }

  Object _heroTagFor(int i) {
    if (!widget.enableHero) return 'no-hero-$i';
    final custom = widget.heroTags;
    if (custom != null && i < custom.length && custom[i] != null) {
      return custom[i]!;
    }
    return 'image-viewer:$i:${widget.images[i].hashCode}';
  }

  Widget _buildImage(int i) {
    return Image(
      image: widget.images[i],
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: _bgOpacity),
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 5,
        title: Text(
          '${_index + 1}/${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(OneContext().context!),
            tooltip: 'cancel'.tr(context: context),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        allowImplicitScrolling: false,
        physics: _zoomedFlag
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
        onPageChanged: (i) {
          setState(() {
            _index = i;
            _resetZoomAndDrag();
          });
        },
        itemCount: widget.images.length,
        itemBuilder: (_, i) {
          return LayoutBuilder(
            builder: (ctx, constraints) {
              final size = constraints.biggest;

              final heroWrapped = widget.enableHero
                  ? HeroMode(
                    enabled: i == _index,
                    child: Hero(
                        tag: _heroTagFor(i),
                        transitionOnUserGestures: true,
                        child: Material(
                          type: MaterialType.transparency,
                          child: _buildImage(i),
                        ),
                      ),
                  )
                  : _buildImage(i);

              return Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  // Double-tap حول نقطة اللمس
                  onDoubleTapDown: (d) => _doubleTapLocal = d.localPosition,
                  onDoubleTap: () => _onDoubleTap(size),
                  // سحب رأسي للخروج: لما مش مكبّر فقط
                  onVerticalDragStart: _zoomedFlag ? null : (_) {},
                  onVerticalDragUpdate:
                      _zoomedFlag ? null : _onVerticalDragUpdate,
                  onVerticalDragEnd: _zoomedFlag ? null : _onVerticalDragEnd,

                  child: Transform.translate(
                    offset: Offset(0, _dragDy),
                    child: InteractiveViewer(
                      panEnabled: _zoomedFlag, // يتحرك بس وقت الزووم
                      transformationController: _transformCtrl,
                      minScale: _minScale,
                      maxScale: _maxScale,
                      clipBehavior: Clip.none,
                      child: heroWrapped,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
