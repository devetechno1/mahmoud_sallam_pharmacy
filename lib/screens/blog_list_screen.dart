import 'package:active_ecommerce_cms_demo_app/app_config.dart';
import 'package:active_ecommerce_cms_demo_app/custom/device_info.dart';
import 'package:active_ecommerce_cms_demo_app/custom/useful_elements.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/locale/custom_localization.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/providers/blog_provider.dart';
import 'package:active_ecommerce_cms_demo_app/screens/blog_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({super.key});

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    Provider.of<BlogProvider>(context, listen: false).fetchBlogs(false);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildBlogList(context),
      backgroundColor: MyTheme.mainColor,
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0.0,
      backgroundColor: MyTheme.mainColor,
      bottom: PreferredSize(
          child: AnimatedContainer(
            //color: MyTheme.textfield_grey,

            duration: const Duration(milliseconds: 500),
          ),
          preferredSize: const Size.fromHeight(0.0)),
      title: buildAppBarTitle(context),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  Widget buildAppBarTitle(BuildContext context) {
    return AnimatedCrossFade(
        firstChild: buildAppBarTitleOption(context),
        secondChild: buildAppBarSearchOption(context),
        firstCurve: Curves.fastOutSlowIn,
        secondCurve: Curves.fastOutSlowIn,
        crossFadeState: _showSearchBar
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 500));
  }

  Container buildAppBarTitleOption(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 37),
      child: Row(
        children: [
          Container(
            width: 20,
            margin: const EdgeInsetsDirectional.only(
                end: AppDimensions.paddingDefault),
            child: UsefulElements.backButton(color: "black"),
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: AppDimensions.paddingSupSmall),
              child: Text(
                'all_blogs_ucf'.tr(context: context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // SizedBox(
          //     width: 20,
          //     child: GestureDetector(
          //         onTap: () {
          //           _showSearchBar = true;
          //           setState(() {});
          //         },
          //         child: Image.asset(AppImages.search)))
        ],
      ),
    );
  }

  Container buildAppBarSearchOption(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      width: DeviceInfo(context).width,
      height: 40,
      child: TextField(
        controller: _searchController,
        onTap: () {},
        onChanged: (txt) {},
        onSubmitted: (txt) {},
        autofocus: false,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () {
              _showSearchBar = false;
              setState(() {});
            },
            icon: const Icon(
              Icons.clear,
              color: MyTheme.grey_153,
            ),
          ),
          filled: true,
          fillColor: MyTheme.white.withValues(alpha: 0.6),
          hintText:
              'search_in_blogs'.tr(context: context) //widget.category_name!
          ,
          hintStyle: const TextStyle(fontSize: 14.0, color: MyTheme.font_grey),
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: MyTheme.noColor, width: 0.0),
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusHalfSmall)),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: MyTheme.noColor, width: 0.0),
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusHalfSmall)),
          contentPadding: const EdgeInsets.all(8.0),
        ),
      ),
    );
  }

  Widget buildBlogList(context) {
    return RefreshIndicator(
      onRefresh: Provider.of<BlogProvider>(context, listen: false).fetchBlogs,
      child: Consumer<BlogProvider>(
        builder: (context, blogProvider, child) {
          if (blogProvider.isLoading) {
            return ShimmerHelper()
                .buildListShimmer(item_count: 10, item_height: 100.0);
          } else {
            if (blogProvider.blogs.isEmpty) {
              return Center(
                child: Text(
                  'no_data_is_available'.tr(context: context),
                  style: const TextStyle(color: MyTheme.font_grey),
                ),
              );
            }
            return MasonryGridView.count(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              crossAxisCount: 2,
              itemCount: blogProvider.blogs.length,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlogDetailsScreen(
                            blog: blogProvider.blogs[index],
                          ),
                        ));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusDefault),
                      image: DecorationImage(
                        image: NetworkImage(blogProvider.blogs[index]
                            .banner), // Replace with your image asset
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions
                          .radiusDefault), // Ensure the gradient follows the border radius
                      child: Stack(
                        children: [
                          // Gradient overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.5),
                                    Colors.black.withValues(alpha: 0.5)
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Centering the text content
                          Container(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 113, 10, 18),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    blogProvider.blogs[index].title,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    blogProvider.blogs[index].title,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    blogProvider.blogs[index].shortDescription,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
