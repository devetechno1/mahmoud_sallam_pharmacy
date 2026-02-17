import 'package:active_ecommerce_cms_demo_app/data_model/address_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../app_config.dart';
import '../../../helpers/shared_value_helper.dart';
import '../../../other_config.dart';
import '../../../presenter/home_provider.dart';
import '../../../services/push_notification_service.dart';
import 'build_app_bar.dart';
import 'product_loading_container.dart';
import 'whatsapp_floating_widget.dart';

class GlobalHomeScreenWidget extends StatefulWidget {
  const GlobalHomeScreenWidget({
    Key? key,
    this.goBack = true,
    this.slivers = const [],
  }) : super(key: key);

  final bool goBack;
  final List<Widget> slivers;

  @override
  _GlobalHomeScreenWidgetState createState() => _GlobalHomeScreenWidgetState();
}

class _GlobalHomeScreenWidgetState extends State<GlobalHomeScreenWidget>
    with SingleTickerProviderStateMixin {
  late final HomeProvider provider = context.read<HomeProvider>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        if (OtherConfig.USE_PUSH_NOTIFICATION)
          PushNotificationService.updateDeviceToken();
        provider.onRefresh();
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.goBack,
      child: SafeArea(
        top: false,
        child: Selector<HomeProvider, Address?>(
          selector: (_, provider) => provider.defaultAddress,
          builder: (context, s, child) {
            return Scaffold(
              appBar: AppBar(
                toolbarHeight: 0,
                backgroundColor: Theme.of(context).primaryColor,
                systemOverlayStyle: SystemUiOverlayStyle.light,
              ),
              floatingActionButton: whatsappFloatingButtonWidget,
              backgroundColor: Colors.white,
              body: Stack(
                children: [
                  RefreshIndicator(
                    color: Theme.of(context).primaryColor,
                    backgroundColor: Colors.white,
                    onRefresh: provider.onRefresh,
                    displacement: 0,
                    edgeOffset: 125,
                    child: NotificationListener<ScrollUpdateNotification>(
                      onNotification: (notification) {
                        provider.paginationListener(notification.metrics);
                        return false;
                      },
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        slivers: [
                          BuildAppBar(
                            context: context,
                            showAddress: is_logged_in.$ &&
                                AppConfig
                                    .businessSettingsData.sellerWiseShipping,
                          ),
                          ...widget.slivers,
                        ],
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.center,
                    child: ProductLoadingContainer(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
