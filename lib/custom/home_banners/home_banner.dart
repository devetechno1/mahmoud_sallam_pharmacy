// import 'package:flutter/material.dart';
// import '../../data_model/slider_response.dart';
// import '../../services/navigation_service.dart';
// import '../aiz_image.dart';
// import '../dynamic_size_image_banner.dart';

// class BannerHome extends StatefulWidget {
//   final bool isBannersInitial;
//   final List<AIZSlider> bannersImagesList;
//   final double aspectRatio;
//   final bool makeOneBannerDynamicSize;

//   const BannerHome({
//     Key? key,
//     required this.isBannersInitial,
//     required this.bannersImagesList,
//     this.aspectRatio = 1,
//     this.makeOneBannerDynamicSize = true,
//   }) : super(key: key);

//   @override
//   State<BannerHome> createState() => _BannerHomeState();
// }

// class _BannerHomeState extends State<BannerHome> {
//   int _currentIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     if (widget.isBannersInitial && widget.bannersImagesList.isEmpty) {
//       return const LoadingImageBannerWidget();
//     }

//     if (widget.bannersImagesList.isNotEmpty) {
//       if (widget.bannersImagesList.length == 1 &&
//           widget.makeOneBannerDynamicSize) {
//         return DynamicSizeImageBanner(
//           urlToOpen: widget.bannersImagesList.first.url,
//           photo: widget.bannersImagesList.first.photo,
//         );
//       }

//       final banners = widget.bannersImagesList;

//       final List<List<AIZSlider>> pages = [];
//       for (int i = 0; i < banners.length; i += 4) {
//         final end = (i + 4 < banners.length) ? i + 4 : banners.length;
//         pages.add(banners.sublist(i, end));
//       }

//       return Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(10),
//               color: Colors.white,
//               boxShadow: const [
//                 BoxShadow(
//                   color: Colors.grey,
//                   spreadRadius: 5,
//                   blurRadius: 2,
//                   offset: Offset(0, 1),
//                 ),
//               ],
//             ),
//             height: 345,
//             child: PageView.builder(
//               itemCount: pages.length,
//               onPageChanged: (index) {
//                 setState(() => _currentIndex = index);
//               },
//               itemBuilder: (context, index) {
//                 final images = pages[index];
//                 if (images.length == 1) {
//                   return Center(
//                     child: FractionallySizedBox(
//                       widthFactor: 0.9,
//                       child: _buildBanner(images[0],),
//                     ),
//                   );
//                 }

//                 if (images.length < 4) {
//                   return Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: images
//                         .map((e) => SizedBox(
//                               width: MediaQuery.sizeOf(context).width / 2 - 30,
//                               child: _buildBanner(e),
//                             ))
//                         .toList(),
//                   );
//                 }
//                 return Column(
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           flex: 3,
//                           child: Column(
//                             children: [
//                               _buildBanner(images[0]),
//                               const SizedBox(height: 8),
//                               _buildBanner(images[1]),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           flex: 3,
//                           child: SizedBox(
//                             height: 200,
//                             child: _buildBanner(images[2]),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 4),
//                     _buildBanner(images[3]),
//                   ],
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: 10),
//           if (pages.length > 1)
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(
//                 pages.length,
//                 (index) {
//                   return AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     width: _currentIndex == index ? 12 : 8,
//                     height: 8,
//                     margin: const EdgeInsets.symmetric(horizontal: 4),
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: _currentIndex == index
//                           ? Colors.black
//                           : Colors.grey.shade400,
//                     ),
//                   );
//                 },
//               ),
//             ),
//         ],
//       );
//     }

//     return emptyWidget;
//   }

//   Widget _buildBanner(AIZSlider slider,double aspectRatio) {
//     return AspectRatio(
//       aspectRatio: aspectRatio,
//      // aspectRatio: 3,
//       child: Container(
//         margin: const EdgeInsets.all(2),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: InkWell(
//             onTap: () => NavigationService.handleUrls(slider.url),
//             child: AIZImage.radiusImage(
//               slider.photo,
//               0,
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
