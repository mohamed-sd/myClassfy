// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';

import 'package:eClassify/data/cubits/category/fetch_category_cubit.dart';
import 'package:eClassify/data/cubits/chat/blocked_users_list_cubit.dart';
import 'package:eClassify/data/cubits/chat/get_buyer_chat_users_cubit.dart';
import 'package:eClassify/data/cubits/favorite/favorite_cubit.dart';
import 'package:eClassify/data/cubits/home/fetch_home_all_items_cubit.dart';
import 'package:eClassify/data/cubits/home/fetch_home_screen_cubit.dart';
import 'package:eClassify/data/cubits/slider_cubit.dart';
import 'package:eClassify/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:eClassify/data/cubits/system/get_api_keys_cubit.dart';
import 'package:eClassify/data/helper/designs.dart';
import 'package:eClassify/data/model/home/home_screen_section.dart';
import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/model/system_settings_model.dart';
import 'package:eClassify/ui/screens/ad_banner_screen.dart';
import 'package:eClassify/ui/screens/home/slider_widget.dart';
import 'package:eClassify/ui/screens/home/widgets/category_widget_home.dart';
import 'package:eClassify/ui/screens/home/widgets/grid_list_adapter.dart';
import 'package:eClassify/ui/screens/home/widgets/home_search.dart';
import 'package:eClassify/ui/screens/home/widgets/home_sections_adapter.dart';
import 'package:eClassify/ui/screens/home/widgets/home_shimmers.dart';
import 'package:eClassify/ui/screens/home/widgets/location_widget.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_internet.dart';
import 'package:eClassify/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:eClassify/ui/screens/widgets/shimmerLoadingContainer.dart';
import 'package:eClassify/ui/theme/theme.dart';
//import 'package:uni_links/uni_links.dart';

import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/notification/awsome_notification.dart';
import 'package:eClassify/utils/notification/notification_service.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:eClassify/app/routes.dart';

const double sidePadding = 10;

class HomeScreen extends StatefulWidget {
  final String? from;

  const HomeScreen({super.key, this.from});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<HomeScreen> {
  //
  @override
  bool get wantKeepAlive => true;

  //
  List<ItemModel> itemLocalList = [];

  //
  bool isCategoryEmpty = false;

  //
  late final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    initializeSettings();
    addPageScrollListener();
    notificationPermissionChecker();
    LocalAwesomeNotification().init(context);
    ///////////////////////////////////////
    NotificationService.init(context);
    context.read<SliderCubit>().fetchSlider(
          context,
        );
    context.read<FetchCategoryCubit>().fetchCategories();
    context.read<FetchHomeScreenCubit>().fetch(
        city: HiveUtils.getCityName(),
        areaId: HiveUtils.getAreaId(),
        country: HiveUtils.getCountryName(),
        state: HiveUtils.getStateName());
    context.read<FetchHomeAllItemsCubit>().fetch(
        city: HiveUtils.getCityName(),
        areaId: HiveUtils.getAreaId(),
        radius: HiveUtils.getNearbyRadius(),
        longitude: HiveUtils.getLongitude(),
        latitude: HiveUtils.getLatitude(),
        country: HiveUtils.getCountryName(),
        state: HiveUtils.getStateName());

    if (HiveUtils.isUserAuthenticated()) {
      context.read<FavoriteCubit>().getFavorite();
      //fetchApiKeys();
      context.read<GetBuyerChatListCubit>().fetch();
      context.read<BlockedUsersListCubit>().blockedUsersList();
    }

    _scrollController.addListener(() {
      if (_scrollController.isEndReached()) {
        if (context.read<FetchHomeAllItemsCubit>().hasMoreData()) {
          context.read<FetchHomeAllItemsCubit>().fetchMore(
                city: HiveUtils.getCityName(),
                areaId: HiveUtils.getAreaId(),
                radius: HiveUtils.getNearbyRadius(),
                longitude: HiveUtils.getLongitude(),
                latitude: HiveUtils.getLatitude(),
                country: HiveUtils.getCountryName(),
                stateName: HiveUtils.getStateName(),
              );
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initializeSettings() {
    final settingsCubit = context.read<FetchSystemSettingsCubit>();
    if (!const bool.fromEnvironment("force-disable-demo-mode",
        defaultValue: false)) {
      Constant.isDemoModeOn =
          settingsCubit.getSetting(SystemSetting.demoMode) ?? false;
    }
  }

  void addPageScrollListener() {
    //homeScreenController.addListener(pageScrollListener);
  }

  void fetchApiKeys() {
    context.read<GetApiKeysCubit>().fetch();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: context.color.mainGold,
        ),
        child: Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            actions: [
              SizedBox(
                height: 40,
                width: 40,
                child: Container(
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.favorite_border,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                width: 40,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, Routes.searchScreenRoute,
                        arguments: {
                          "autoFocus": true,
                        });
                  },
                  child: Container(
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.search,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  UiUtils.checkUser(
                      onNotGuest: () {
                        Navigator.pushNamed(
                            context, Routes.notificationPage);
                      },
                      context: context);
                },
                child: SizedBox(
                  height: 40,
                  width: 40,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 3,
              ),
            ],
            title: Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Text(
                "علاء الدين مختار !",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
            elevation: 0,
            leadingWidth: 90,
            leading: Padding(
                padding: EdgeInsetsDirectional.only(
                    start: sidePadding, end: sidePadding),
                child: const LocationWidget()),
            backgroundColor: context.color.mainBrown,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(30),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "اخبار التعدين",
                    style: TextStyle(
                        color: Colors.amber, fontWeight: FontWeight.w800),
                  ),
                  Text(
                      " اتفاقيات بين السودان وبكين لتعدين الذهب والنحاس , بورتسودات : كشفت الشركة السودانية للموارد المعدنية عن وجود اتفاقيات في مجال التعدين مع شركات صينية  ",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w800)),
                ]),
              ),
            ),
          ),
          backgroundColor: context.color.mainBrown,
          body: RefreshIndicator(
              key: _refreshIndicatorKey,
              color: const Color.fromARGB(255, 226, 208, 9),
              onRefresh: () async {
                context.read<SliderCubit>().fetchSlider(
                      context,
                    );
                context.read<FetchCategoryCubit>().fetchCategories();
                context.read<FetchHomeScreenCubit>().fetch(
                    city: HiveUtils.getCityName(),
                    areaId: HiveUtils.getAreaId(),
                    country: HiveUtils.getCountryName(),
                    state: HiveUtils.getStateName());
                context.read<FetchHomeAllItemsCubit>().fetch(
                    city: HiveUtils.getCityName(),
                    areaId: HiveUtils.getAreaId(),
                    radius: HiveUtils.getNearbyRadius(),
                    longitude: HiveUtils.getLongitude(),
                    latitude: HiveUtils.getLatitude(),
                    country: HiveUtils.getCountryName(),
                    state: HiveUtils.getStateName());
              },
              child: Container(
                margin: EdgeInsets.only(top: 100),
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                decoration: BoxDecoration(
                    color: context.color.mainColor,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.zero,
                        bottomRight: Radius.zero)),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  controller: _scrollController,
                  child: Column(
                    children: [
                      SizedBox(height: 20,),
                      BlocBuilder<FetchHomeScreenCubit, FetchHomeScreenState>(
                        builder: (context, state) {
                          if (state is FetchHomeScreenInProgress) {
                            return shimmerEffect();
                          }
                          if (state is FetchHomeScreenSuccess) {
                            return Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                // const HomeSearchField(),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  width: double.infinity,
                                  child: Text(
                                    "اهلا بك في إعلانات بريق!",
                                    textAlign: TextAlign.start,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 22),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "حيث نفتح لك ولإعلاناتك وصولا سريعا الي عالم التعدين ",
                                    textAlign: TextAlign.start,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    "لتصل رسائلك الى المهتمين وتخلق فرصا مشرقة . ",
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                const SliderWidget(),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "إعلانات التعدين بين يديك",
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          "assets/bggold.png"), // أو NetworkImage للرابط الخارجي
                                      fit: BoxFit
                                          .fill, // لجعل الصورة تغطي المساحة بالكامل
                                    ),
                                  ),
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Icon(Icons.keyboard_arrow_down),
                                      Text(
                                        "أقســام بريــق الرئيسيــة",
                                        style:
                                            TextStyle(fontWeight: FontWeight.w900),
                                      ),
                                      Icon(Icons.keyboard_arrow_down),
                                    ],
                                  ),
                                ),
                                const CategoryWidgetHome(),
                                Container(
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    image: DecorationImage(
                                      image: AssetImage(
                                          "assets/bggold.png"), // أو NetworkImage للرابط الخارجي
                                      fit: BoxFit
                                          .fill, // لجعل الصورة تغطي المساحة بالكامل
                                    ),
                                  ),
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Icon(Icons.keyboard_arrow_down),
                                      Text(
                                        " إعلانــات بريــق ",
                                        style:
                                            TextStyle(fontWeight: FontWeight.w900),
                                      ),
                                      Icon(Icons.keyboard_arrow_down),
                                    ],
                                  ),
                                ),
                                ...List.generate(state.sections.length, (index) {
                                  HomeScreenSection section = state.sections[index];
                                  if (state.sections.isNotEmpty) {
                                    return HomeSectionsAdapter(
                                      section: section,
                                    );
                                  } else {
                                    return SizedBox.shrink();
                                  }
                                }),
                                if (state.sections.isNotEmpty &&
                                    Constant.isGoogleBannerAdsEnabled == "1") ...[
                                  Container(
                                    padding: EdgeInsets.only(top: 5),
                                    margin: EdgeInsets.symmetric(vertical: 10),
                                    child:
                                        AdBannerWidget(), // Custom widget for banner ad
                                  )
                                ] else ...[
                                  SizedBox(
                                    height: 10,
                                  )
                                ],
                              ],
                            );
                          }

                          if (state is FetchHomeScreenFail) {
                            print('hey bro ${state.error}');
                          }
                          return SizedBox.shrink();
                        },
                      ),
                      const AllItemsWidget(),
                      const SizedBox(
                        height: 100,
                      )
                    ],
                  ),
                ),
              ),
            ),
        ),
      ),
    );
  }

  Widget shimmerEffect() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 24,
          horizontal: defaultPadding,
        ),
        child: Column(
          children: [
            ClipRRect(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: CustomShimmer(height: 52, width: double.maxFinite),
            ),
            SizedBox(
              height: 12,
            ),
            ClipRRect(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: CustomShimmer(height: 170, width: double.maxFinite),
            ),
            SizedBox(
              height: 12,
            ),
            Container(
              height: 100,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 10,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 8.0),
                    child: const Column(
                      children: [
                        ClipRRect(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: CustomShimmer(
                            height: 70,
                            width: 66,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        CustomShimmer(
                          height: 10,
                          width: 48,
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        const CustomShimmer(
                          height: 10,
                          width: 60,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomShimmer(
                  height: 20,
                  width: 150,
                ),
                /* CustomShimmer(
                  height: 20,
                  width: 50,
                ),*/
              ],
            ),
            Container(
              height: 214,
              margin: EdgeInsets.only(top: 10),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: 5,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: index == 0 ? 0 : 10.0),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: CustomShimmer(
                            height: 147,
                            width: 250,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        CustomShimmer(
                          height: 15,
                          width: 90,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const CustomShimmer(
                          height: 14,
                          width: 230,
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        const CustomShimmer(
                          height: 14,
                          width: 200,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: 16,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: CustomShimmer(
                          height: 147,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      CustomShimmer(
                        height: 15,
                        width: 70,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const CustomShimmer(
                        height: 14,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const CustomShimmer(
                        height: 14,
                        width: 130,
                      ),
                    ],
                  );
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisExtent: 215,
                  crossAxisCount: 2, // Single column grid
                  mainAxisSpacing: 15.0,
                  crossAxisSpacing: 15.0,
                  // You may adjust this aspect ratio as needed
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget sliderWidget() {
    return BlocConsumer<SliderCubit, SliderState>(
      listener: (context, state) {
        if (state is SliderFetchSuccess) {
          setState(() {});
        }
      },
      builder: (context, state) {
        log('State is  $state');
        if (state is SliderFetchInProgress) {
          return const SliderShimmer();
        }
        if (state is SliderFetchFailure) {
          return Container();
        }
        if (state is SliderFetchSuccess) {
          if (state.sliderlist.isNotEmpty) {
            return const SliderWidget();
          }
        }
        return Container();
      },
    );
  }
}

class AllItemsWidget extends StatelessWidget {
  const AllItemsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchHomeAllItemsCubit, FetchHomeAllItemsState>(
      builder: (context, state) {
        if (state is FetchHomeAllItemsSuccess) {
          if (state.items.isNotEmpty) {
            final int crossAxisCount = 2;
            final int items = state.items.length;
            final int total = (items ~/ crossAxisCount) +
                (items % crossAxisCount != 0 ? 1 : 0);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GridListAdapter(
                    type: ListUiType.List,
                    crossAxisCount: 2,
                    builder: (context, int index, bool isGrid) {
                      int itemIndex = index * crossAxisCount;
                      return SizedBox(
                        height: MediaQuery.sizeOf(context).height / 3.5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int i = 0; i < crossAxisCount; ++i) ...[
                              Expanded(
                                  child: itemIndex + 1 <= items
                                      ? ItemCard(item: state.items[itemIndex++])
                                      : SizedBox.shrink()),
                              if (i != crossAxisCount - 1)
                                SizedBox(
                                  width: 15,
                                )
                            ]
                          ],
                        ),
                      );
                    },
                    listSeparator: (context, index) {
                      if (index == 0 ||
                          index % Constant.nativeAdsAfterItemNumber != 0) {
                        return SizedBox(
                          height: 15,
                        );
                      } else {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 5,
                            ),
                            AdBannerWidget(),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        );
                      }
                    },
                    total: total),
                if (state.isLoadingMore) UiUtils.progress(),
              ],
            );
          } else {
            return SizedBox.shrink();
          }
        }
        if (state is FetchHomeAllItemsFail) {
          if (state.error is ApiException) {
            if (state.error.error == "no-internet") {
              return Center(child: NoInternet());
            }
          }

          return const SomethingWentWrong();
        }
        return SizedBox.shrink();
      },
    );
  }
}

Future<void> notificationPermissionChecker() async {
  if (!(await Permission.notification.isGranted)) {
    await Permission.notification.request();
  }
}
