import 'package:flutter/material.dart';
import 'package:flutter_base/presentation_module/shared_view/layout/wrapper_layout.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, _) => MaterialApp(home: child),
    );
  }

  testWidgets('renders title, body, actions, and custom background', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        WrapperLayoutView(
          args: WrapperLayoutArgs(
            title: 'Example title',
            backgroundColor: Colors.amber,
            body: const Text('Body content'),
            actions: const [Icon(Icons.settings)],
          ),
        ),
      ),
    );

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));

    expect(find.text('Example title'), findsOneWidget);
    expect(find.text('Body content'), findsOneWidget);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(scaffold.backgroundColor, Colors.amber);
  });

  testWidgets('calls back and close handlers from leading buttons', (
    tester,
  ) async {
    var backCalled = false;
    var closeCalled = false;

    await tester.pumpWidget(
      buildSubject(
        Column(
          children: [
            Expanded(
              child: WrapperLayoutView(
                args: WrapperLayoutArgs(
                  title: 'Back',
                  showBack: true,
                  onBack: () => backCalled = true,
                  body: const SizedBox.shrink(),
                ),
              ),
            ),
            Expanded(
              child: WrapperLayoutView(
                args: WrapperLayoutArgs(
                  title: 'Close',
                  showClose: true,
                  onClose: () => closeCalled = true,
                  body: const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.arrow_back).first);
    await tester.tap(find.byIcon(Icons.close).first);

    expect(backCalled, isTrue);
    expect(closeCalled, isTrue);
  });

  testWidgets(
    'supports custom title, hidden app bar, gradient, and bottom bar',
    (tester) async {
      await tester.pumpWidget(
        buildSubject(
          WrapperLayoutView(
            args: const WrapperLayoutArgs(
              isHideAppBar: true,
              customTitle: Text('Custom title'),
              isBackgroundGradient: true,
              backgroundGradientColors: [Colors.red, Colors.blue],
              body: Text('Body only'),
              bottomNavigationBar: Text('Bottom action'),
            ),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      final decoratedBoxes = tester.widgetList<DecoratedBox>(
        find.byType(DecoratedBox),
      );

      expect(scaffold.appBar, isNull);
      expect(find.text('Custom title'), findsNothing);
      expect(find.text('Body only'), findsOneWidget);
      expect(find.text('Bottom action'), findsOneWidget);
      expect(
        decoratedBoxes.any(
          (box) =>
              box.decoration is BoxDecoration &&
              (box.decoration as BoxDecoration).gradient is LinearGradient,
        ),
        isTrue,
      );
    },
  );
}
