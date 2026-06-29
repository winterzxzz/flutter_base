import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../extensions/extensions.dart';
import '../../shared_view/shared_view.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return WrapperLayoutView(
      args: WrapperLayoutArgs(
        title: 'Page not found',
        bodyPadding: EdgeInsets.all(24.r),
        body: Center(
          child: Text(
            'Route not found',
            style: textTheme.titleMedium?.copyWith(fontSize: 18.r),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
