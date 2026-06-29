import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../configs/configs.dart';
import '../../extensions/extensions.dart';
import '../../shared_view/shared_view.dart';
import 'home_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return WrapperLayoutView(
      args: WrapperLayoutArgs(
        title: AppConstants.appTitle,
        bodyPadding: EdgeInsets.all(24.r),
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final textTheme = context.textTheme;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ready for features',
                    style: textTheme.headlineMedium?.copyWith(fontSize: 28.r),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    AppConstants.appSubtitle,
                    style: textTheme.bodyLarge?.copyWith(fontSize: 16.r),
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      '${state.count}',
                      style: textTheme.displayLarge?.copyWith(fontSize: 64.r),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Remove',
                          icon: Icons.remove,
                          onPressed: context.read<HomeCubit>().decrement,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: AppButton(
                          label: 'Add',
                          icon: Icons.add,
                          onPressed: context.read<HomeCubit>().increment,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
