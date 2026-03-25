import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class TestViewport {
  const TestViewport({required this.name, required this.size});

  final String name;
  final Size size;
}

const phoneMinViewport = TestViewport(name: 'phone-min', size: Size(360, 800));

const phonePrimaryIosViewport = TestViewport(
  name: 'phone-primary-ios',
  size: Size(390, 844),
);

const phonePrimaryAndroidViewport = TestViewport(
  name: 'phone-primary-android',
  size: Size(412, 915),
);

const tabletPortraitViewport = TestViewport(
  name: 'tablet-portrait',
  size: Size(768, 1024),
);

const tabletLandscapeViewport = TestViewport(
  name: 'tablet-landscape',
  size: Size(1024, 768),
);

void withViewport(WidgetTester tester, TestViewport viewport) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = viewport.size;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Future<void> withSurfaceViewport(
  LiveTestWidgetsFlutterBinding binding,
  TestViewport viewport,
) async {
  await binding.setSurfaceSize(viewport.size);
  addTearDown(() async {
    await binding.setSurfaceSize(null);
  });
}

void forEachViewport(
  List<TestViewport> viewports,
  String description,
  Future<void> Function(WidgetTester tester, TestViewport viewport) body,
) {
  for (final viewport in viewports) {
    testWidgets('$description (${viewport.name})', (tester) async {
      withViewport(tester, viewport);
      await body(tester, viewport);
    });
  }
}
