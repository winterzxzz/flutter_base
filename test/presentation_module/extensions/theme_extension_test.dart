import 'package:flutter/material.dart';
import 'package:flutter_base/presentation_module/extensions/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BuildContext exposes theme, textTheme, and colorScheme', (
    tester,
  ) async {
    late BuildContext capturedContext;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(capturedContext.theme, Theme.of(capturedContext));
    expect(capturedContext.textTheme, Theme.of(capturedContext).textTheme);
    expect(capturedContext.colorScheme, Theme.of(capturedContext).colorScheme);
  });
}
