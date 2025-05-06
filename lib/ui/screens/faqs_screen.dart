import 'package:eClassify/data/cubits/fetch_faqs_cubit.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_data_found.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_internet.dart';
import 'package:eClassify/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:eClassify/ui/screens/widgets/intertitial_ads_screen.dart';
import 'package:eClassify/ui/screens/widgets/shimmerLoadingContainer.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({super.key});

  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return const FaqsScreen();
      },
    );
  }

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> {
  @override
  void initState() {
    AdHelper.loadInterstitialAd();
    context.read<FetchFaqsCubit>().fetchFaqs();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AdHelper.showInterstitialAd();
    return RefreshIndicator(
      color: context.color.territoryColor,
      onRefresh: () async {
        context.read<FetchFaqsCubit>().fetchFaqs();
      },
      child: Scaffold(
        backgroundColor: context.color.mainColor,
        appBar: UiUtils.buildAppBar(context,
            backgroundColor: context.color.mainBrown,
            showBackButton: true, title: "faqsLbl".translate(context)),
        body: BlocBuilder<FetchFaqsCubit, FetchFaqsState>(
          builder: (context, state) {
            if (state is FetchFaqsInProgress) {
              return buildFaqsShimmer();
            }
            if (state is FetchFaqsFailure) {
              if (state.errorMessage is ApiException) {
                if (state.errorMessage.error == "no-internet") {
                  return NoInternet(
                    onRetry: () {
                      context.read<FetchFaqsCubit>().fetchFaqs();
                    },
                  );
                }
              }
              return const SomethingWentWrong();
            }
            if (state is FetchFaqsSuccess) {
              if (state.faqModel.isEmpty) {
                return const NoDataFound();
              }
              return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 7),
                  itemCount: state.faqModel.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                  offset: Offset(0, 2),
                                  blurStyle: BlurStyle.normal
                              ),]
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        child: ExpansionPanelList.radio(
                          expandedHeaderPadding: EdgeInsets.only(bottom: 0),
                          children: [
                            ExpansionPanelRadio(
                              backgroundColor: context.color.secondaryColor,
                              body: ListTile(
                                title: Container(
                                  margin: EdgeInsets.only(bottom: 5),
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    border:Border.all(
                                      color: Colors.grey,
                                      width: 1
                                    ),
                                  ),
                                  child: CustomText(
                                    state.faqModel[index].answer!,
                                    fontSize: context.font.normal,
                                  ),
                                ),
                              ),
                              headerBuilder: (context, isExpanded) {
                                return ListTile(
                                    title: CustomText(
                                  state.faqModel[index].question!,
                                  fontWeight: FontWeight.bold,
                                  fontSize: context.font.normal,
                                      color: context.color.mainBrown,
                                ));
                              },
                              value: index,
                              canTapOnHeader: true,
                            ),
                          ],
                          elevation: 0.0,
                          animationDuration: const Duration(milliseconds: 700),
                          expansionCallback: (int item, bool status) {
                            setState(
                              () {
                                state.faqModel[index].isExpanded = !status;
                              },
                            );
                          },
                        ));
                  });
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget buildFaqsShimmer() {
    return ListView.builder(
        itemCount: 7,
        shrinkWrap: true,
        padding: EdgeInsets.only(top: 7),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
            child: CustomShimmer(
              borderRadius: 0,
              width: double.infinity,
              height: 60,
            ),
          );
        });
  }
}
