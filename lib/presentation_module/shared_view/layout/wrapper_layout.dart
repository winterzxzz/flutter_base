import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../extensions/extensions.dart';

const List<Color> _defaultGradientColors = [
  Color(0xFF67E1D2),
  Color(0xFF54A8FF),
];
const List<double> _defaultGradientStops = [0.0394, 0.9646];
const double _defaultGradientAngleDegrees = 204.56;
final double _defaultGradientRotationRadians =
    (_defaultGradientAngleDegrees - 90) * (math.pi / 180);

class WrapperLayoutArgs {
  const WrapperLayoutArgs({
    required this.body,
    this.title,
    this.customTitle,
    this.showClose = false,
    this.showBack = false,
    this.centerTitle = false,
    this.backgroundColor = const Color(0xFFEBF3F2),
    this.actions,
    this.onClose,
    this.onBack,
    this.titleStyle,
    this.extendBodyBehindAppBar = false,
    this.isBackgroundGradient = false,
    this.backgroundGradientColors = _defaultGradientColors,
    this.backgroundGradientStops = _defaultGradientStops,
    this.backgroundGradientRotationRadians,
    this.bottom,
    this.bottomHeight = 0,
    this.isCanPop = true,
    this.isHideAppBar = false,
    this.bottomNavigationBar,
    this.appBarBackgroundColor,
    this.leading,
    this.backIcon = Icons.arrow_back,
    this.closeIcon = Icons.close,
    this.bodyPadding = EdgeInsets.zero,
    this.resizeToAvoidBottomInset = false,
  });

  final String? title;
  final Widget? customTitle;
  final Widget body;
  final bool showClose;
  final bool showBack;
  final bool centerTitle;
  final Color? backgroundColor;
  final List<Widget>? actions;
  final VoidCallback? onClose;
  final VoidCallback? onBack;
  final TextStyle? titleStyle;
  final bool extendBodyBehindAppBar;
  final bool isBackgroundGradient;
  final List<Color> backgroundGradientColors;
  final List<double> backgroundGradientStops;
  final double? backgroundGradientRotationRadians;
  final PreferredSizeWidget? bottom;
  final double bottomHeight;
  final bool isCanPop;
  final bool isHideAppBar;
  final Widget? bottomNavigationBar;
  final Color? appBarBackgroundColor;
  final Widget? leading;
  final IconData backIcon;
  final IconData closeIcon;
  final EdgeInsets bodyPadding;
  final bool resizeToAvoidBottomInset;
}

class WrapperLayoutView extends StatelessWidget {
  const WrapperLayoutView({super.key, required this.args});

  final WrapperLayoutArgs args;

  @override
  Widget build(BuildContext context) {
    final scaffold = PopScope(
      canPop: args.isCanPop,
      child: Scaffold(
        resizeToAvoidBottomInset: args.resizeToAvoidBottomInset,
        backgroundColor: args.isBackgroundGradient
            ? Colors.transparent
            : args.backgroundColor,
        extendBodyBehindAppBar: args.extendBodyBehindAppBar,
        appBar: args.isHideAppBar ? null : _buildAppBar(context),
        body: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 1.sh),
          child: Padding(padding: args.bodyPadding.r, child: args.body),
        ),
        bottomNavigationBar: args.bottomNavigationBar,
      ),
    );

    if (!args.isBackgroundGradient) {
      return ColoredBox(
        color: args.backgroundColor ?? Colors.transparent,
        child: scaffold,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: args.backgroundGradientColors,
          stops: args.backgroundGradientStops,
          transform: GradientRotation(
            args.backgroundGradientRotationRadians ??
                _defaultGradientRotationRadians,
          ),
        ),
      ),
      child: scaffold,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: args.centerTitle,
      leading: _buildLeading(context),
      title: _buildTitle(context),
      titleSpacing: 0,
      actions: args.actions,
      backgroundColor: args.isBackgroundGradient
          ? Colors.transparent
          : args.appBarBackgroundColor ?? args.backgroundColor,
      elevation: 0,
      bottom: args.bottom,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (args.leading != null) return args.leading;
    if (args.showClose) {
      return Padding(
        padding: EdgeInsets.only(left: 8.w),
        child: IconButton(
          icon: Icon(args.closeIcon),
          onPressed: args.onClose ?? () => Navigator.maybePop(context),
        ),
      );
    }
    if (args.showBack) {
      return Padding(
        padding: EdgeInsets.only(left: 8.w),
        child: IconButton(
          icon: Icon(args.backIcon),
          onPressed: args.onBack ?? () => Navigator.maybePop(context),
        ),
      );
    }
    return null;
  }

  Widget? _buildTitle(BuildContext context) {
    final textTheme = context.textTheme;
    if (args.customTitle != null) return args.customTitle;
    final title = args.title;
    if (title == null) return null;
    return Text(
      title,
      style:
          args.titleStyle ??
          textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20.r,
          ),
    );
  }
}
