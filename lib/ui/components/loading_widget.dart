import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:surfy_mobile_app/utils/surfy_theme.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({super.key, required this.opacity});

  final double opacity;

  @override
  State<StatefulWidget> createState() {
    return _LoadingWidgetState();
  }

}

class _LoadingWidgetState extends State<LoadingWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: SurfyColor.black.withOpacity(widget.opacity),
      ),
      child: Center(
        child: LottieBuilder.asset(
          "assets/images/animation_loading.json",
          width: 100,
        )
      ),
    );
  }

}