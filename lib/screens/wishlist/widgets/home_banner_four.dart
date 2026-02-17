// import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
// import 'package:active_ecommerce_cms_demo_app/screens/flash_deal/flash_deal_banner.dart';
// import 'package:flutter/material.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:provider/provider.dart';

// class HomeBannerFour extends StatefulWidget {
//   @override
//   _HomeRState createState() => _HomeRState();
// }

// class _HomeRState extends State<HomeBannerFour> {
//   @override
//   void initState() {
//     super.initState();
//     // Loading banners after the first frame is rendered
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<BannerProvider>(context, listen: false).loadBanners();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<BannerProvider>(
//       builder: (context, bannerProvider, child) {
//         if (bannerProvider.banners.isEmpty) {
//           return ShimmerHelper().buildBasicShimmer(height: 237);
//         } else {
//           return Padding(
//             padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
//             child: CarouselSlider(
//               items: bannerProvider.banners.map((banner) {
//                 return Padding(
//                   padding: const EdgeInsets.only(
//                       left: 12, right: 0, top: 0, bottom: 20),
//                   child: Container(
//                     height: 237,
//                     width: 230,

//                     // decoration: BoxDecoration(
//                     //   borderRadius: BorderRadius.circular(AppDimensions.radiusNormal),
//                     //   image: DecorationImage(
//                     //     image: NetworkImage(banner.banner!),
//                     //     fit: BoxFit.cover,
//                     //   ),
//                     // ),
//                     decoration: BoxDecoration(
//                       color: Colors.white, // background color for container
//                       borderRadius:
//                           BorderRadius.circular(AppDimensions.radiusNormal), // rounded corners
//                       boxShadow: [
//                         BoxShadow(
//                           color: Color(0xff000000)
//                               .withValues(alpha: 0.1), // shadow color
//                           spreadRadius: 2, // spread radius
//                           blurRadius: 5, // blur radius
//                           offset: Offset(0, 3), // changes position of shadow
//                         ),
//                       ],
//                       image: DecorationImage(
//                         image: NetworkImage(banner.banner!),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//               options: CarouselOptions(
//                 height: 237.0,
//                 // enlargeCenterPage: true,
//                 initialPage: 0,
//                 viewportFraction: .60,
//                 padEnds: false,
//                 autoPlay: true,
//                 aspectRatio: 1,
//                 // autoPlayCurve: Curves.fastOutSlowIn,
//                 enableInfiniteScroll: true,
//                 autoPlayAnimationDuration: Duration(milliseconds: 800),
//               ),
//             ),
//           );
//         }
//       },
//     );
//   }
// }
