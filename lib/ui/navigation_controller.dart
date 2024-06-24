import 'package:go_router/go_router.dart';

abstract class INavigationLifeCycle {
  void onPageStart();
  void onPageEnd();
}


class NavigationController {
  final Map<int, INavigationLifeCycle> map = {};
  int currentIndex = 0;

  void addListener(int index, INavigationLifeCycle item) {
    map[index] = item;
  }

  void onPageStart(int index) {
    map[index]?.onPageStart();
  }

  void onPageEnd(int index) {
    map[index]?.onPageEnd();
  }
}