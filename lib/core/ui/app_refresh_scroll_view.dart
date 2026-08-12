import 'package:flutter/material.dart';

class AppRefreshScrollView extends StatelessWidget {
  const AppRefreshScrollView({
    super.key,
    required this.child,
    required this.onRefresh,
    this.padding,
  });

  final Widget child;
  final RefreshCallback onRefresh;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        child: child,
      ),
    );
  }
}
