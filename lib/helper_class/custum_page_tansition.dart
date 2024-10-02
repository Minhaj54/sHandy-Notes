import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  final PageTransitionType type;

  const CustomPageTransitionBuilder({required this.type});

  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return PageTransition(
      type: type,
      child: child,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300),
      settings: route.settings,
    ).buildTransitions(
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}
