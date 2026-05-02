import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neo_game_suit/core/utils/responsive_layout.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool showBackButton;
  final double? toolbarHeight;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    required this.title,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showBackButton = true,
    this.toolbarHeight = kToolbarHeight * 0.6,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveLayout.getScreenSize(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        toolbarHeight: toolbarHeight,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
              )
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: screenSize == ScreenSize.large
              ? ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: body,
                )
              : body,
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
