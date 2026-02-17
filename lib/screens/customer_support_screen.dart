import 'dart:async';
import 'package:active_ecommerce_cms_demo_app/screens/orders/order_details.dart' show OrderDetails;
import 'package:flutter/material.dart';
import '../constants/app_images.dart';
import '../data_model/address_response.dart' as res;
import '../data_model/order_mini_response.dart';
import '../locale/custom_localization.dart';
import '../repositories/address_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/wallet_repository.dart';
import 'support_chat_bubble.dart';
import 'support_widgets/support_app_bar.dart';
import 'support_widgets/support_quick_actions.dart';
import 'support_widgets/support_order_card.dart';
import 'support_widgets/support_address_card.dart';
import 'support_widgets/support_wallet_card.dart';

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  State<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  final ScrollController _chatScroll = ScrollController();
  final List<SupportMsg> _messages = [];

  // Orders State
  final List<Order> _orderList = [];
  bool _loadingOrders = false;
  String? _ordersError;
  int _page = 1;
  final String _paymentStatusKey = '';
  final String _deliveryStatusKey = '';

  // Addresses State
  final List<res.Address> _shippingAddressList = [];
  bool _loadingAddresses = false;
  String? _addressesError;

  @override
  void dispose() {
    _chatScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: SupportAppBar(
        onClose: () => Navigator.pop(context),
        rightWidget: Image.asset(AppImages.squareLogo, width: 26),
      ),
      body: Column(
        children: [
          SupportQuickActions(
            onOrdersPressed: _onOrdersPressed,
            onAddressesPressed: _onAddressesPressed,
            onWalletPressed: _onWalletPressed,
          ),

          Expanded(
            child: ListView.builder(
              controller: _chatScroll,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                return SupportChatBubble(msg: _messages[i]);
              },
            ),
          ),
          
          SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                 color:  Colors.white,
              ),
             
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              margin:const EdgeInsets.only(bottom: 10,left: 10,right: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100, // Light grey background for input area
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _actionInputController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'please_enter_your_choice'.tr(context: context),
                          hintStyle:const TextStyle(color: Colors.grey, fontSize: 12),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _handleQuickActionInput,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor, 
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  final TextEditingController _actionInputController = TextEditingController();

  void _handleQuickActionInput() {
    final text = _actionInputController.text.trim();
    if (text.isEmpty) return;

    final number = int.tryParse(text);
    if (number != null) {
      switch (number) {
        case 1:
          _onOrdersPressed();
          break;
        case 2:
          _onAddressesPressed();
          break;
        case 3:
          _onWalletPressed();
          break;
      }
    }
    _actionInputController.clear();
  }

  // -------------------- Logic --------------------

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chatScroll.hasClients) return;
      _chatScroll.animateTo(
        _chatScroll.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _addUserText(String text) {
    setState(() {
      _messages.add(SupportMsg.user(text));
    });
    _scrollToBottom();
  }

  void _addBotText(String text) {
    setState(() {
      _messages.add(SupportMsg.botText(text));
    });
    _scrollToBottom();
  }

  void _addBotWidget(Widget w) {
    setState(() {
      _messages.add(SupportMsg.botOrders(w));
    });
    _scrollToBottom();
  }

  // -------------------- Orders --------------------

  Future<void> fetchOrders({bool reset = true}) async {
    if (reset) {
      _page = 1;
      _orderList.clear();
    }

    setState(() {
      _loadingOrders = true;
      _ordersError = null;
    });

    try {
      final orderResponse = await OrderRepository().getOrderList(
        page: _page,
        payment_status: _paymentStatusKey,
        delivery_status: _deliveryStatusKey,
      );

      final orders = orderResponse.orders ?? [];

      setState(() {
        _orderList.addAll(orders);
        if (orders.isNotEmpty) _page++;
      });
    } catch (e) {
      setState(() {
        _ordersError = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingOrders = false;
      });
    }
  }

  Future<void> _onOrdersPressed() async {
    _addUserText('orders_ucf'.tr(context: context));

    await fetchOrders(reset: true);

    if (_ordersError != null) {
      _addBotText(_ordersError!);
      return;
    }

    if (_orderList.isEmpty) {
      _addBotText('no_orders_found'.tr(context: context));
      return;
    }

    final List<Order> ordersSnapshot = List<Order>.from(_orderList);

    _addBotWidget(
      SizedBox(
        height: 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: ordersSnapshot.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) => SupportOrderCard(
            order: ordersSnapshot[i],
            onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) {
                return OrderDetails(id: ordersSnapshot[i].id);
              }));
            },
          ),
        ),
      ),
    );
  }

  // -------------------- Addresses --------------------

  Future<void> fetchAddresses() async {
    setState(() {
      _loadingAddresses = true;
      _addressesError = null;
    });

    try {
      final res.AddressResponse addressResponse =
          await AddressRepository().getAddressList();

      final list = addressResponse.addresses ?? [];

      setState(() {
        _shippingAddressList
          ..clear()
          ..addAll(list);
      });
    } catch (e) {
      setState(() {
        _addressesError = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingAddresses = false;
      });
    }
  }

  Future<void> _onAddressesPressed() async {
    _addUserText('addresses_of_user'.tr(context: context));

    await fetchAddresses();

    if (_addressesError != null) {
      _addBotText(_addressesError!);
      return;
    }

    if (_shippingAddressList.isEmpty) {
      _addBotText('no_address_is_added'.tr(context: context));
      return;
    }

    final List<res.Address> listSnapshot = List<res.Address>.from(_shippingAddressList);

    _addBotWidget(
      SizedBox(
        height: 170,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: listSnapshot.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) => SupportAddressCard(
            address: listSnapshot[i],
            index: i,
          ),
        ),
      ),
    );
  }

  // -------------------- Wallet --------------------

  Future<void> _onWalletPressed() async {
    _addUserText('my_wallet_ucf'.tr(context: context));

    try {
      final balanceDetails = await WalletRepository().getBalance();
      
      _addBotWidget(
        SupportWalletCard(balanceDetails: balanceDetails),
      );
    } catch (e) {
      _addBotText(e.toString());
    }
  }
}
