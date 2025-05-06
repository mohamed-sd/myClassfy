import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class CategoryHomeCard extends StatelessWidget {
  final String title;
  final String url;
  final VoidCallback onTap;
  const CategoryHomeCard({
    super.key,
    required this.title,
    required this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String extension = url.split(".").last.toLowerCase();
    bool isFullImage = false;

    if (extension == "png" || extension == "svg") {
      isFullImage = false;
    } else {
      isFullImage = true;
    }
    return SizedBox(
      width: 90,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            child: Column(
              children: [
                if (isFullImage) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: 130,
                      width: double.infinity,
                      color: Colors.white,
                      child: Column(children: [
                        Stack(alignment: Alignment.bottomCenter, children: [
                          UiUtils.imageType(
                              height: 130, url, fit: BoxFit.cover),
                          Expanded(
                              child: Padding(
                                  padding: EdgeInsets.all(3),
                                  child: CustomText(
                                    title,
                                    textAlign: TextAlign.center,
                                    maxLines: 3,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  )))
                        ])
                      ]),
                    ),
                  ),
                ] else ...[
                  Container(
                    clipBehavior: Clip.antiAlias,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: context.color.borderColor.darken(60),
                          width: 1),
                      color: context.color.secondaryColor,
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          // color: Colors.blue,
                          width: 48,
                          height: 48,
                          child: UiUtils.imageType(url, fit: BoxFit.fitWidth),
                        ),
                      ),
                    ),
                  ),
                ],
                // Expanded(
                //     child: Padding(
                //         padding: const EdgeInsets.all(0.0),
                //         child: CustomText(
                //           title,
                //           textAlign: TextAlign.center,
                //           maxLines: 2,
                //           fontSize: context.font.smaller,
                //           color: context.color.textDefaultColor,
                //         )))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
