import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadableWidget extends StatefulWidget {
  LoadableWidget({super.key,
    required this.child,
    required this.loadingTemplate,
    required this.isLoading,
  });

  final Widget child;
  final Widget loadingTemplate;
  final bool isLoading;

  @override
  State<StatefulWidget> createState() {
    return _LoadableWidgetState();
  }

}

class _LoadableWidgetState extends State<LoadableWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return widget.loadingTemplate;
    } else {
      return widget.child;
    }
  }

}