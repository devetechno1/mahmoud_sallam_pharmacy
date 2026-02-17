// lib/custom/paged_view/paged_view.dart
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/grid_responsive.dart';
import 'package:active_ecommerce_cms_demo_app/custom/paged_view/models/page_result.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

import '../../main.dart';
import '../../my_theme.dart';
import '../box_decorations.dart';

typedef PageFetcher<T> = Future<PageResult<T>> Function(int page);
typedef ItemBuilder<T> = Widget Function(
    BuildContext context, T item, int index);
typedef LoadingItemBuilder = Widget Function(BuildContext context, int index);
typedef EmptyBuilder = Widget Function(BuildContext context);

enum PagedLayout { list, grid, masonry }

/// Controller for [PagedView] to allow external imperative actions.
class PagedViewController<T> {
  _PagedViewState<T>? _state;

  /// Whether the controller is currently attached to a [PagedView].
  bool get hasClients => _state != null && _state!.mounted;

  /// Current page index inside the attached [PagedView], or null if detached.
  int? get currentPage => _state?._page;

  /// Whether the [PagedView] is fetching the first page.
  bool get isLoading => _state?._isLoading ?? false;

  /// Whether the [PagedView] is fetching more pages.
  bool get isLoadingMore => _state?._isLoadingMore ?? false;

  /// Whether there are more pages to load.
  bool get hasMore => _state?._hasMore ?? false;

  // ---- Attach / Detach (internal) ----
  void _attach(_PagedViewState<T> state) {
    _state = state;
  }

  void _detach(_PagedViewState<T> state) {
    if (identical(_state, state)) {
      _state = null;
    }
  }

  /// Reload data from the first page. By default scrolls to top without animation.
  Future<void> refresh({bool jumpToTop = true}) async {
    final s = _state;
    if (s == null || !s.mounted) return;
    await s._resetToFirstPage(jumpToTop: jumpToTop);
  }

  /// Reset to a specific [page] and reload. If null, uses the widget's [initialPage].
  Future<void> reset({int? page, bool jumpToTop = true}) async {
    final s = _state;
    if (s == null || !s.mounted) return;
    await s._reset(page: page, jumpToTop: jumpToTop);
  }

  /// Programmatically load the next page if available.
  Future<void> loadNextPage() async {
    final s = _state;
    if (s == null || !s.mounted) return;
    if (!s._hasMore || s._isLoadingMore) return;
    await s._loadMore();
  }

  /// Scroll to the top of the list/grid.
  Future<void> jumpToTop({bool animate = true}) async {
    final s = _state;
    if (s == null || !s.mounted) return;
    await s._jumpToTop(animate: animate);
  }
}

class PagedView<T> extends StatefulWidget {
  const PagedView({
    super.key,
    required this.fetchPage,
    required this.itemBuilder,
    this.controller,
    this.layout = PagedLayout.list,

    // Grid settings
    this.gridCrossAxisCount = 2,
    this.gridAspectRatio = 1,
    this.gridMainAxisExtent,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,

    // Padding + Scroll
    this.padding = const EdgeInsets.all(16),
    this.physics,

    // Paging
    this.preloadTriggerFraction = 0.8,
    this.initialPage = 1,
    this.enableRefresh = true,
    this.refreshEdgeOffset = 0.0,

    // Placeholders
    this.loadingItemBuilder,
    this.loadingPlaceholdersCount = 6,
    this.loadingMoreBuilder,
    this.emptyBuilder,

    // Responsive
    this.responsiveGrid = true,
    this.minTileWidth = 180,
    this.useResponsiveAspectRatio = true,
    this.usePrimaryScrollController = false,
  });

  // Data
  final PagedViewController<T>? controller;
  final PageFetcher<T> fetchPage;
  final ItemBuilder<T> itemBuilder;

  // Layout
  final PagedLayout layout;

  // Grid settings
  final int gridCrossAxisCount;
  final double gridAspectRatio;
  final double? gridMainAxisExtent;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  // Padding + Scroll
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? physics;

  // Paging
  final double preloadTriggerFraction;
  final int initialPage;
  final bool enableRefresh;
  final double refreshEdgeOffset;

  // Placeholders
  final LoadingItemBuilder? loadingItemBuilder;
  final int loadingPlaceholdersCount;
  final Widget Function(BuildContext context)? loadingMoreBuilder;
  final EmptyBuilder? emptyBuilder;

  // Responsive
  final bool responsiveGrid;
  final double minTileWidth;
  final bool useResponsiveAspectRatio;
  final bool usePrimaryScrollController;

  @override
  State<PagedView<T>> createState() => _PagedViewState<T>();
}

class _PagedViewState<T> extends State<PagedView<T>> {
  ScrollController? _localScrollController;
  ScrollController get _scrollController {
    if (widget.usePrimaryScrollController) {
      return PrimaryScrollController.of(context);
    }
    return _localScrollController!;
  }

  int _page = 1;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final List<T> _items = [];

  int get cross => _effectiveCrossAxisCount();
  double get ratio => _aspectRatioForWidth();

  @override
  void initState() {
    super.initState();
    // Attach controller if provided
    widget.controller?._attach(this);
    if (!widget.usePrimaryScrollController) {
      _localScrollController = ScrollController();
    }
    _page = widget.initialPage;

    // Determine when to listen for scroll events
    // With PrimaryScrollController, we might need a post-frame callback or
    // just rely on didChangeDependencies if we want to be safe, but typically
    // accessing .of(context) in initState is unsafe if we immediately add listener.
    // However, for typical usage, waiting for build is safer, or adding listener in didChangeDependencies.
    // simpler: add listener in waiting for frame or rely on manual attach.
    // actually, let's just do it in didChangeDependencies for primary,
    // and here for local.
    if (!widget.usePrimaryScrollController) {
      _loadFirstPage();
      _localScrollController!.addListener(_onScroll);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadFirstPage();
        _scrollController.addListener(_onScroll);
      });
    }
  }

  @override
  void didUpdateWidget(covariant PagedView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-attach controller if it changed.
    if (!identical(widget.controller, oldWidget.controller)) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
  }

  void _onScroll() {
    if (_isLoadingMore || !_hasMore) return;
    final position = _scrollController.position;

    // Trigger load-more on bottom edge (better UX for short lists)
    if (position.atEdge && position.pixels > 0) {
      _loadMore();
      return;
    }

    final triggerPx = position.maxScrollExtent * widget.preloadTriggerFraction;
    if (position.pixels >= triggerPx) {
      _loadMore();
    }
  }

  Future<void> _loadFirstPage([bool showLoading = true]) async {
    // Safety: ensure we are not far scrolled when clearing items (avoids Masonry assertion)
    if (_scrollController.hasClients && _scrollController.position.pixels > 0) {
      _scrollController.jumpTo(0);
    }
    setState(() {
      if (showLoading) _isLoading = true;
      _hasMore = true;
    });
    try {
      final res = await widget.fetchPage(_page);

      if (!mounted) return;
      setState(() {
        _items.clear();
        _items.addAll(res.data);
        _hasMore = res.hasMore;
        _isLoading = false;
      });
      _maybePrefetchToFillViewport();
    } catch (_, st) {
      recordError(_, st);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    try {
      _page += 1;
      final res = await widget.fetchPage(_page);
      if (!mounted) return;
      setState(() {
        _items.addAll(res.data);
        _hasMore = res.hasMore;
        _isLoadingMore = false;
      });
    } catch (_, st) {
      recordError(_, st);
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  void _maybePrefetchToFillViewport() {
    // If first page doesn't fill the viewport, prefetch next page (smoother UX)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_hasMore) return;
      if (!_scrollController.hasClients) return;
      final pos = _scrollController.position;
      if (pos.maxScrollExtent <= 0) {
        _loadMore();
      }
    });
  }

  // ===== Imperative helpers (used by PagedViewController) =====
  Future<void> _resetToFirstPage({
    bool showLoading = true,
    bool jumpToTop = true,
  }) async {
    await _reset(
      showLoading: showLoading,
      page: widget.initialPage,
      jumpToTop: jumpToTop,
    );
  }

  Future<void> _reset({
    bool showLoading = true,
    int? page,
    bool jumpToTop = true,
  }) async {
    final nextPage = page ?? widget.initialPage;
    _page = nextPage;
    _hasMore = false;
    if (jumpToTop) {
      await _jumpToTop(animate: false);
    }
    await _loadFirstPage(showLoading);
  }

  Future<void> _jumpToTop({bool animate = true}) async {
    if (!_scrollController.hasClients) return;
    if (animate) {
      await _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    if (!widget.usePrimaryScrollController) {
      _localScrollController?.removeListener(_onScroll);
      _localScrollController?.dispose();
    } else {
      // We don't own the primary controller, but we should remove our listener
      try {
        // It might be disposed already, but good practice to try removing listener
        _scrollController.removeListener(_onScroll);
      } catch (e) {
        // ignore
      }
    }
    super.dispose();
  }

  // ===== Builders =====

  Widget _customLoading(context, index) {
    return Shimmer.fromColors(
      baseColor: MyTheme.shimmer_base,
      highlightColor: MyTheme.shimmer_highlighted,
      child: Container(
        height: (index + 1) % 2 != 0 ? 250 : 300,
        width: double.infinity,
        decoration: BoxDecorations.buildBoxDecoration_1(),
      ),
    );
  }

  Widget _buildLoadingSliver(BuildContext context) {
    final LoadingItemBuilder customLoading =
        widget.loadingItemBuilder ?? _customLoading;
    switch (widget.layout) {
      case PagedLayout.list:
        return SliverList.separated(
          separatorBuilder: (_, __) => SizedBox(height: widget.mainAxisSpacing),
          itemCount: widget.loadingPlaceholdersCount,
          itemBuilder: (c, i) => customLoading(c, i),
        );
      case PagedLayout.grid:
        return SliverPadding(
          padding: widget.padding,
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              mainAxisSpacing: widget.mainAxisSpacing,
              crossAxisSpacing: widget.crossAxisSpacing,
              childAspectRatio: ratio,
              mainAxisExtent: widget.gridMainAxisExtent,
            ),
            delegate: SliverChildBuilderDelegate(
              (c, i) => customLoading(c, i),
              childCount: widget.loadingPlaceholdersCount,
            ),
          ),
        );
      case PagedLayout.masonry:
        return SliverPadding(
          padding: widget.padding,
          sliver: SliverMasonryGrid.count(
            crossAxisCount: cross,
            mainAxisSpacing: widget.mainAxisSpacing,
            crossAxisSpacing: widget.crossAxisSpacing,
            childCount: widget.loadingPlaceholdersCount,
            itemBuilder: (c, i) => customLoading(c, i),
          ),
        );
    }
  }

  Widget _buildGridSliver(BuildContext context) {
    return SliverPadding(
      padding: widget.padding,
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: widget.mainAxisSpacing,
          crossAxisSpacing: widget.crossAxisSpacing,
          childAspectRatio: ratio,
          mainAxisExtent: widget.gridMainAxisExtent,
        ),
        delegate: SliverChildBuilderDelegate(
          (c, i) => widget.itemBuilder(c, _items[i], i),
          childCount: _items.length,
        ),
      ),
    );
  }

  Widget _buildMasonrySliver(BuildContext context) {
    return SliverPadding(
      padding: widget.padding,
      sliver: SliverMasonryGrid.count(
        crossAxisCount: cross,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
        childCount: _items.length,
        itemBuilder: (c, i) => widget.itemBuilder(c, _items[i], i),
      ),
    );
  }

  // ===== Responsive helpers (via GridResponsive) =====
  int _effectiveCrossAxisCount() {
    if (!widget.responsiveGrid) return widget.gridCrossAxisCount;
    return GridResponsive.columnsForWidth(context,
        minTileWidth: widget.minTileWidth);
  }

  double _aspectRatioForWidth() {
    final explicit = widget.gridAspectRatio;
    if (explicit > 0) return explicit;
    return GridResponsive.aspectRatioForWidth(
      context,
      useResponsiveAspectRatio: widget.useResponsiveAspectRatio,
    );
  }

  @override
  Widget build(BuildContext context) {
    // If using primary scroll controller, we must set primary: true and controller: null
    final bool isPrimary = widget.usePrimaryScrollController;
    final ScrollController? controllerToUse =
        isPrimary ? null : _scrollController;

    final body = CustomScrollView(
      controller: controllerToUse,
      primary: isPrimary,
      physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (_isLoading)
          _buildLoadingSliver(context)
        else if (_items.isEmpty)
          SliverToBoxAdapter(
            child: (widget.emptyBuilder != null)
                ? widget.emptyBuilder!(context)
                : SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.6,
                    child: Center(
                      child: Text('no_data_is_available'.tr(context: context)),
                    ),
                  ),
          )
        else
          switch (widget.layout) {
            PagedLayout.list => SliverList.separated(
                itemCount: _items.length,
                separatorBuilder: (_, __) =>
                    SizedBox(height: widget.mainAxisSpacing),
                itemBuilder: (c, i) => widget.itemBuilder(c, _items[i], i),
              ),
            PagedLayout.grid => _buildGridSliver(context),
            PagedLayout.masonry => _buildMasonrySliver(context),
          },
        if (_isLoadingMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: widget.loadingMoreBuilder?.call(context) ??
                    const CupertinoActivityIndicator(),
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
      ],
    );

    if (!widget.enableRefresh) return body;

    return RefreshIndicator.adaptive(
      edgeOffset: widget.refreshEdgeOffset,
      onRefresh: () async {
        await _resetToFirstPage(showLoading: false);
      },
      child: body,
    );
  }
}
