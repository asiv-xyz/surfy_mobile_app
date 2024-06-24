import 'package:flutter/material.dart';
import 'package:surfy_mobile_app/ui/navigation_controller.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HistoryPageState();
  }
}

class _HistoryPageState extends State<HistoryPage> implements INavigationLifeCycle {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('History Page')
      )
    );
  }

  @override
  void onPageEnd() {
    print('onPageEnd');
  }

  @override
  void onPageStart() {
    print('onPageStart');
  }

}