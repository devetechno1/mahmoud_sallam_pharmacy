import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/num_ex.dart';
import 'package:animated_text_lerp/animated_text_lerp.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data_model/cart_response.dart';
import '../data_model/product_details_response.dart';
import '../helpers/system_config.dart';
import '../my_theme.dart';
import '../presenter/cart_provider.dart';
import '../presenter/cart_counter.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';

import '../screens/product/product_details.dart';
import 'wholesale_text_widget.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';

class CartSellerItemCardWidget extends StatefulWidget {
  final int sellerIndex;
  final int itemIndex;
  final CartProvider cartProvider;
  final int index;

  const CartSellerItemCardWidget({
    Key? key,
    required this.cartProvider,
    required this.sellerIndex,
    required this.itemIndex,
    required this.index,
  }) : super(key: key);

  @override
  State<CartSellerItemCardWidget> createState() => _CartSellerItemCardWidgetState();
}

class _CartSellerItemCardWidgetState extends State<CartSellerItemCardWidget> {
  bool _isQtyUpdating = false;

  CartProvider get cartProvider => widget.cartProvider;
  int get sellerIndex => widget.sellerIndex;
  int get itemIndex => widget.itemIndex;
  int get index => widget.index;


  _CartUnitRow _buildUnitRow({
    required int id,
    required String name,
    required String? multiplierStr,
    required BuildContext context,
  }) {
    final m = int.tryParse((multiplierStr ?? '1').split('.').first) ?? 1;
    final cleanName = name.trim().isEmpty
        ? 'quantity_ucf'.tr(context: context)
        : name.trim();
    return _CartUnitRow(
      id: id,
      name: cleanName,
      multiplier: m <= 0 ? 1 : m,
    );
  }

  List<_CartUnitRow> _buildAllUnitRows(BuildContext context, ProductUnit? pu) {
    if (pu == null) return const <_CartUnitRow>[];

    final rows = <_CartUnitRow>[];

    // Base unit
    rows.add(
      _buildUnitRow(
        context: context,
        id: pu.id ?? 0,
        name: pu.short_name ?? pu.actual_name ?? '',
        multiplierStr: pu.base_unit_multiplier,
      ),
    );

    // Sub units
    final subs = pu.sub_units ?? const <ProductUnit>[];
    for (final s in subs) {
      final n = (s.short_name ?? s.actual_name ?? '').trim();
      if (n.isEmpty) continue;
      rows.add(
        _buildUnitRow(
          context: context,
          id: s.id ?? 0,
          name: n,
          multiplierStr: s.base_unit_multiplier,
        ),
      );
    }

    // Dedup by id
    final seen = <int>{};
    return rows.where((e) => seen.add(e.id)).toList();
  }

  /// Greedy decomposition (like product details) from base quantity to (largest -> smallest) units.
  Map<int, int> _computeUnitCounts(int baseQty, List<_CartUnitRow> units) {
    if (units.isEmpty) return const <int, int>{};

    final sorted = [...units]
      ..sort((a, b) => b.multiplier.compareTo(a.multiplier));

    int remaining = baseQty < 0 ? 0 : baseQty;
    final out = <int, int>{};

    for (final u in sorted) {
      final m = u.multiplier <= 0 ? 1 : u.multiplier;
      final c = remaining ~/ m;
      out[u.id] = c < 0 ? 0 : c;
      remaining = remaining % m;
    }

    return out;
  }

  Future<void> _qtyIncrease(BuildContext context) {
    return Future<void>.sync(
      () => cartProvider.onQuantityIncrease(context, sellerIndex, itemIndex),
    );
  }

  Future<void> _qtyDecrease(BuildContext context) {
    return Future<void>.sync(
      () => cartProvider.onQuantityDecrease(context, sellerIndex, itemIndex),
    );
  }

  int _currentQty() {
    return cartProvider.shopList[sellerIndex].cartItems![itemIndex].quantity;
  }

  String _currentPriceRaw() {
    return cartProvider.shopList[sellerIndex].cartItems![itemIndex].price ?? '';
  }

  Future<void> _waitForQtyAndPrice(
    BuildContext context, {
    required int expectedQty,
    required String fromPrice,
  }) async {
    // Ensure spinner renders at least 1 frame.
    await Future<void>.delayed(const Duration(milliseconds: 16));

    // Give enough time for the server to recalculate and return the new price.
    const int maxMs = 15000;
    const int stepMs = 50;
    int elapsed = 0;

    while (elapsed < maxMs) {
      if (!context.mounted) return;

      final q = _currentQty();
      final p = _currentPriceRaw();

      // IMPORTANT: keep loader until BOTH quantity is applied AND price response is updated.
      if (q == expectedQty && p != fromPrice) return;

      await Future<void>.delayed(const Duration(milliseconds: stepMs));
      elapsed += stepMs;
    }
  }

  Future<void> _withQtyLoading(
    BuildContext context, {
    required int expectedQty,
    required String fromPrice,
    required Future<void> Function() action,
  }) async {
    if (_isQtyUpdating) return;

    setState(() => _isQtyUpdating = true);

    try {
      await action();
      await _waitForQtyAndPrice(
        context,
        expectedQty: expectedQty,
        fromPrice: fromPrice,
      );
    } finally {
      if (mounted) setState(() => _isQtyUpdating = false);
    }
  }


  /// Apply delta in base units using existing CartProvider (+/- 1 base each call).
  Future<void> _applyBaseDelta(BuildContext context, CartItem item, int deltaBase) async {
    if (deltaBase == 0) return;

    final int fromQty = item.quantity;
    final String fromPrice = item.price ?? '';

    final int target = fromQty + deltaBase;
    if (target < item.minQuantity) {
      ToastComponent.showDialog(
        'minimumOrderQuantity'.tr(
          context: context,
          args: {"minQuantity": "${item.minQuantity}"},
        ),
        isError: true,
      );
      return;
    }
    if (target > item.maxQuantity) {
      ToastComponent.showDialog(
        'maxOrderQuantityLimit'.tr(
          context: context,
          args: {"maxQuantity": "${item.maxQuantity}"},
        ),
        isError: true,
      );
      return;
    }

    await _withQtyLoading(
      context,
      expectedQty: target,
      fromPrice: fromPrice,
      action: () async {
        if (deltaBase > 0) {
          for (int i = 0; i < deltaBase; i++) {
            await _qtyIncrease(context);
              // Notify product details (and others) to refresh in-cart quantities immediately.
    if (context.mounted) {
      Provider.of<CartCounter>(context, listen: false).notifyListeners();
    }
}
          return;
        }

        final int steps = (-deltaBase);
        for (int i = 0; i < steps; i++) {
          final int nextQty = fromQty - (i + 1);
          if (nextQty < item.minQuantity) break;
          await _qtyDecrease(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final CartItem item = cartProvider.shopList[sellerIndex].cartItems![itemIndex];
    final bool hasWholesale = makeNewVisualWholesale(item.wholesales);

    final bool hasUnitPanel = item.productUnit != null && (item.productUnit?.sub_units ?? const <ProductUnit>[]).isNotEmpty;

    final unitRows = hasUnitPanel
        ? _buildAllUnitRows(context, item.productUnit)
        : const <_CartUnitRow>[];

    final bool showBasicQty = !hasUnitPanel && !hasWholesale && !item.isDigital;

    // Use DESC order for display like the mock (largest first: حاوية/كرتونة/عبوة)
    final unitsDesc = [...unitRows]..sort((a, b) => b.multiplier.compareTo(a.multiplier));
    final unitCounts = _computeUnitCounts(item.quantity, unitsDesc);

    // Layout sizes (match the provided mock)
    const double topCardHeight = 96.0;
    const double unitRowHeight = 33.0;
    const double unitPanelVPadding = 8.0;

    final double unitPanelHeight = unitsDesc.isEmpty
        ? 0.0
        : (unitPanelVPadding * 2.5) + (unitsDesc.length * unitRowHeight);

    final double totalHeight = topCardHeight + (unitsDesc.isEmpty ? 0.0 : (10 + unitPanelHeight));

    return SizedBox(
      height: totalHeight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top card (image + name/price + trash)
          Container(
            height: topCardHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                // Product image box
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: AppDimensions.paddingSmall,
                    end: AppDimensions.paddingSmall,
                  ),
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
                      child: FadeInImage.assetNetwork(
                        placeholder: AppImages.placeholder,
                        image: item.productThumbnailImage ?? '',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // Title + price
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: AppDimensions.paddingSmall,
                      top: AppDimensions.paddingSmall,
                      bottom: AppDimensions.paddingSmall,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.productName ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: MyTheme.font_grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedNumberText<double>(
                          double.tryParse((item.price ?? '').replaceAll(RegExp('[^0-9.]'), '')) ?? 0.0,
                          duration: const Duration(milliseconds: 500),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          formatter: (value) {
                            return '${value.withSeparator} ${SystemConfig.systemCurrency?.symbol ?? ''}'.trim();
                          },
                        ),

                        if (hasWholesale)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: WholesaleAddedData(
                              itemIndex: itemIndex,
                              sellerIndex: sellerIndex,
                              auctionProduct: item.auctionProduct,
                              wholesales: item.wholesales,
                              cartProvider: cartProvider,
                            ),
                          ),

                        if (item.isNotAvailable)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'notAvailable'.tr(context: context),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Old quantity controls (fallback when no units/sub_units)
                // REQUIRED: show it NEXT TO the trash block (not inside it).
                if (showBasicQty)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: _BasicQtyColumn(
                      quantity: item.quantity,
                      canPlus: (item.auctionProduct == 0),
                      canMinus: (item.auctionProduct == 0),
                      onPlus: () => _applyBaseDelta(context, item, 1),
                      onMinus: () => _applyBaseDelta(context, item, -1),
                    ),
                  ),

                
                // Loader (left of trash) while quantity/price updates
                SizedBox(
                  width: 34,
                  height: topCardHeight,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: _isQtyUpdating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),

// Trash area (right block) - trash ONLY
                Container(
                  width: 64,
                  height: topCardHeight,
                  decoration: const BoxDecoration(
                    border: BorderDirectional(
                      start: BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                  ),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        cartProvider.onPressDelete(
                          context,
                          item.id.toString(),
                          sellerIndex,
                          itemIndex,
                        );
                      },
                      child: Image.asset(
                        AppImages.trash,
                        height: 22,
                        color: const Color(0xFF6D6D6D),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Unit panel (base + sub units)
          if (unitsDesc.isNotEmpty)
            Container(
              height: unitPanelHeight,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusHalfSmall),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: unitPanelVPadding,
                  horizontal: AppDimensions.paddingSmall,
                ),
                child: Column(
                  children: unitRows.map((u) {
                    final count = unitCounts[u.id] ?? 0;
                    final canMinus = (item.auctionProduct == 0) && (count > 0) && ((item.quantity - u.multiplier) >= item.minQuantity);
                    final canPlus = (item.auctionProduct == 0) && ((item.quantity + u.multiplier) <= item.maxQuantity);

                    return SizedBox(
                      height: unitRowHeight,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              u.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          _UnitCircleButton(
                            icon: Icons.remove,
                            enabled: canMinus,
                            onTap: () => _applyBaseDelta(context, item, -u.multiplier),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 24,
                            child: Text(
                              '$count',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: MyTheme.font_grey,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _UnitCircleButton(
                            icon: Icons.add,
                            enabled: canPlus,
                            onTap: () => _applyBaseDelta(context, item, u.multiplier),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CartUnitRow {
  final int id;
  final String name;
  final int multiplier;

  const _CartUnitRow({
    required this.id,
    required this.name,
    required this.multiplier,
  });
}

class _UnitCircleButton extends StatefulWidget {
  final IconData icon;
  final bool enabled;
  final Future<void> Function() onTap;

  const _UnitCircleButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_UnitCircleButton> createState() => _UnitCircleButtonState();
}

class _UnitCircleButtonState extends State<_UnitCircleButton> {
  bool _loading = false;

  Future<void> _handleTap() async {
    if (_loading || !widget.enabled) return;
    final start = DateTime.now();
    setState(() => _loading = true);
    try {
      // Guarantee at least one frame so the indicator actually appears.
      await Future<void>.delayed(const Duration(milliseconds: 16));
      await widget.onTap();
    } finally {
      // Keep it visible for a minimum duration (even if the update is instant).
      final elapsed = DateTime.now().difference(start);
      const minShow = Duration(milliseconds: 350);
      if (elapsed < minShow) {
        await Future<void>.delayed(minShow - elapsed);
      }
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (widget.enabled && !_loading) ? _handleTap : null,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFBDBDBD), width: 1),
        ),
        child: Center(
          child: _loading
              ? const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  widget.icon,
                  size: 10,
                  color: const Color(0xFF4E5254),
                ),
        ),
      ),
    );
  }
}

class _BasicQtyButton extends StatefulWidget {
  final IconData icon;
  final bool enabled;
  final Future<void> Function() onTap;

  const _BasicQtyButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_BasicQtyButton> createState() => _BasicQtyButtonState();
}

class _BasicQtyButtonState extends State<_BasicQtyButton> {
  bool _loading = false;

  Future<void> _handleTap() async {
    if (_loading || !widget.enabled) return;
    final start = DateTime.now();
    setState(() => _loading = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 16));
      await widget.onTap();
    } finally {
      final elapsed = DateTime.now().difference(start);
      const minShow = Duration(milliseconds: 350);
      if (elapsed < minShow) {
        await Future<void>.delayed(minShow - elapsed);
      }
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (widget.enabled && !_loading) ? _handleTap : null,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFBDBDBD), width: 1),
        ),
        child: Center(
          child: _loading
              ? const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  widget.icon,
                  size: 10,
                  color: widget.enabled ? const Color(0xFF4E5254) : const Color(0xFFBDBDBD),
                ),
        ),
      ),
    );
  }
}

class _BasicQtyColumn extends StatelessWidget {
  final int quantity;
  final bool canPlus;
  final bool canMinus;
  final Future<void> Function() onPlus;
  final Future<void> Function() onMinus;

  const _BasicQtyColumn({
    required this.quantity,
    required this.canPlus,
    required this.canMinus,
    required this.onPlus,
    required this.onMinus,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _BasicQtyButton(
            icon: Icons.add,
            enabled: canPlus,
            onTap: onPlus,
          ),
          const SizedBox(height: 6),
          Text(
            '$quantity',
            style: const TextStyle(
              color: MyTheme.font_grey,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          _BasicQtyButton(
            icon: Icons.remove,
            enabled: canMinus,
            onTap: onMinus,
          ),
        ],
      ),
    );
  }
}

class WholesaleAddedData extends StatelessWidget {
  const WholesaleAddedData({
    super.key,
    required this.wholesales,
    required this.cartProvider,
    required this.sellerIndex,
    required this.itemIndex,
    required this.auctionProduct,
  });

  final List<Wholesale> wholesales;
  final CartProvider cartProvider;
  final int sellerIndex;
  final int itemIndex;
  final int? auctionProduct;

  @override
  Widget build(BuildContext context) {
    final CartItem item = cartProvider.shopList[sellerIndex].cartItems![itemIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.paddingSmall,
      ),
      child: Row(
        children: [
          _MiniQtyBtn(
            icon: Icons.add,
            enabled: auctionProduct == 0,
            onTap: () async {
              if (auctionProduct != 0) return;
              final fromQty = cartProvider.shopList[sellerIndex].cartItems![itemIndex].quantity;
              cartProvider.onQuantityIncrease(context, sellerIndex, itemIndex);
              // wait until quantity changes (shows loading in UI)
              const int maxMs = 5000;
              const int stepMs = 50;
              int elapsed = 0;
              await Future<void>.delayed(const Duration(milliseconds: 16));
              while (elapsed < maxMs) {
                if (!context.mounted) return;
                final q = cartProvider.shopList[sellerIndex].cartItems![itemIndex].quantity;
                if (q != fromQty) return;
                await Future<void>.delayed(const Duration(milliseconds: stepMs));
                elapsed += stepMs;
              }
            },
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          Expanded(
            child: WholesaleTextWidget(
              wholesales: wholesales,
              quantity: item.quantity,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingSmall),
          _MiniQtyBtn(
            icon: Icons.remove,
            enabled: auctionProduct == 0,
            onTap: () async {
              if (auctionProduct != 0) return;
              final fromQty = cartProvider.shopList[sellerIndex].cartItems![itemIndex].quantity;
              cartProvider.onQuantityDecrease(context, sellerIndex, itemIndex);
              const int maxMs = 5000;
              const int stepMs = 50;
              int elapsed = 0;
              await Future<void>.delayed(const Duration(milliseconds: 16));
              while (elapsed < maxMs) {
                if (!context.mounted) return;
                final q = cartProvider.shopList[sellerIndex].cartItems![itemIndex].quantity;
                if (q != fromQty) return;
                await Future<void>.delayed(const Duration(milliseconds: stepMs));
                elapsed += stepMs;
              }
            },
          ),
        ],
      ),
    );
  }
}

class _MiniQtyBtn extends StatefulWidget {
  final IconData icon;
  final bool enabled;
  final Future<void> Function() onTap;

  const _MiniQtyBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_MiniQtyBtn> createState() => _MiniQtyBtnState();
}

class _MiniQtyBtnState extends State<_MiniQtyBtn> {
  bool _loading = false;

  Future<void> _handleTap() async {
    if (_loading || !widget.enabled) return;
    final start = DateTime.now();
    setState(() => _loading = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 16));
      await widget.onTap();
    } finally {
      final elapsed = DateTime.now().difference(start);
      const minShow = Duration(milliseconds: 350);
      if (elapsed < minShow) {
        await Future<void>.delayed(minShow - elapsed);
      }
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (widget.enabled && !_loading) ? _handleTap : null,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Center(
          child: _loading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  widget.icon,
                  size: 14,
                  color: widget.enabled ? Theme.of(context).primaryColor : const Color(0xFFBDBDBD),
                ),
        ),
      ),
    );
  }
}