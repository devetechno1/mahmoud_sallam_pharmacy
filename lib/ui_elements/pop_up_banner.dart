import 'package:active_ecommerce_cms_demo_app/helpers/string_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';
import '../data_model/popup_banner_model.dart';
import '../services/navigation_service.dart';

class PopupBannerDialog extends StatelessWidget {
  final PopupBannerModel popupBannerModel;
  const PopupBannerDialog({super.key, required this.popupBannerModel});
  @override
  Widget build(BuildContext context) {
    return Align(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppDimensions.constrainedBoxDefaultWidth,
        ),
        child: Dialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(),
          child: Stack(
    children: [      
       InkWell(
          onTap: () {
          Navigator.pop(context);
          NavigationService.handleUrls(popupBannerModel.btnLink);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              if ((popupBannerModel.image ?? '').trim().isNotEmpty) ...[
                AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    width: double.infinity,
                    fit: BoxFit.cover,
                    imageUrl: popupBannerModel.image ?? '',
                  ),
                ),
              ],
            ],
          ),

          if ((popupBannerModel.title ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: AppDimensions.paddingDefault),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingDefault,
              ),
              child: SizedBox(
                width: double.maxFinite,
                child: Text(
                  popupBannerModel.title ?? '',
                  textDirection: (popupBannerModel.title ?? '').direction,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ],

          if ((popupBannerModel.summary ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: AppDimensions.paddingSmall),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingDefault,
              ),
              child: SizedBox(
                width: double.maxFinite,
                child: Text(
                  popupBannerModel.summary ?? '',
                  textDirection: (popupBannerModel.summary ?? '').direction,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],

          if ((popupBannerModel.btnText ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: AppDimensions.paddingDefault),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingDefault,
                vertical: AppDimensions.paddingSupSmall,
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  NavigationService.handleUrls(popupBannerModel.btnLink);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    AppDimensions.paddingVeryExtraLarge,
                  ),
                  backgroundColor: popupBannerModel.btnBackgroundColor,
                  shape: const RoundedRectangleBorder(),
                ),
                child: Text(
                  popupBannerModel.btnText ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    ), 
    Positioned(
      top: AppDimensions.paddingSmall,
      right: AppDimensions.paddingSmall,
      child: IgnorePointer(
        ignoring: false,
        child: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.close, size: 15),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    ),
  ],
),       
        ),
      ),
    );
  }
}
