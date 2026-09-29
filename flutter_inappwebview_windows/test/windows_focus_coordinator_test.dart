import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_windows/src/in_app_webview/windows_focus_coordinator.dart';

void main() {
  testWidgets('webview hit keeps native focus; overlay and outside hits release it', (tester) async {
    var releases = 0;
    final view = WindowsWebViewFocusHandle(
      release: () async {
        releases++;
      },
    );
    WindowsFocusCoordinator.register(view);
    addTearDown(() => WindowsFocusCoordinator.unregister(view));
    await tester.pumpWidget(
      MaterialApp(
        home: Stack(
          children: [
            Positioned.fill(
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (event) => WindowsFocusCoordinator.claimPointer(event.pointer),
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              width: 100,
              height: 100,
              child: GestureDetector(onTap: () {}, behavior: HitTestBehavior.opaque, child: const SizedBox.expand()),
            ),
          ],
        ),
      ),
    );
    WindowsFocusCoordinator.nativeFocusChanged(view, true);
    await tester.tapAt(const Offset(200, 200));
    expect(releases, 0);
    await tester.tapAt(const Offset(30, 30));
    expect(releases, 1);
    await tester.tapAt(const Offset(30, 30));
    expect(releases, 1);
  });

  testWidgets('Flutter text input wins in both native and Flutter event orders', (tester) async {
    var releases = 0;
    final view = WindowsWebViewFocusHandle(
      release: () async {
        releases++;
      },
    );
    final node = FocusNode();
    addTearDown(node.dispose);
    WindowsFocusCoordinator.register(view);
    addTearDown(() => WindowsFocusCoordinator.unregister(view));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TextField(focusNode: node)),
      ),
    );
    WindowsFocusCoordinator.nativeFocusChanged(view, true);
    node.requestFocus();
    await tester.pump();
    expect(releases, 1);
    WindowsFocusCoordinator.nativeFocusChanged(view, true);
    expect(releases, 2);
    WindowsFocusCoordinator.nativeFocusChanged(view, false);
    expect(releases, 2);
  });

  testWidgets('multiple views and detached callbacks do not steal focus', (tester) async {
    var firstReleases = 0;
    var secondReleases = 0;
    final first = WindowsWebViewFocusHandle(
      release: () async {
        firstReleases++;
      },
    );
    final second = WindowsWebViewFocusHandle(
      release: () async {
        secondReleases++;
      },
    );
    WindowsFocusCoordinator.register(first);
    WindowsFocusCoordinator.register(second);
    await tester.pumpWidget(const MaterialApp(home: SizedBox.expand()));
    WindowsFocusCoordinator.nativeFocusChanged(first, true);
    WindowsFocusCoordinator.nativeFocusChanged(first, false);
    WindowsFocusCoordinator.nativeFocusChanged(second, true);
    GestureBinding.instance.pointerRouter.route(const PointerDownEvent(pointer: 7));
    expect(firstReleases, 0);
    expect(secondReleases, 1);
    WindowsFocusCoordinator.unregister(first);
    WindowsFocusCoordinator.unregister(second);
    WindowsFocusCoordinator.nativeFocusChanged(second, true);
    GestureBinding.instance.pointerRouter.route(const PointerDownEvent(pointer: 8));
    expect(secondReleases, 1);
  });

  testWidgets('non-text Flutter focus nodes do not fight a webview click', (tester) async {
    var releases = 0;
    final node = FocusNode();
    addTearDown(node.dispose);
    final view = WindowsWebViewFocusHandle(
      release: () async {
        releases++;
      },
    );
    WindowsFocusCoordinator.register(view);
    addTearDown(() => WindowsFocusCoordinator.unregister(view));
    await tester.pumpWidget(
      MaterialApp(
        home: Focus(focusNode: node, child: const SizedBox.expand()),
      ),
    );
    node.requestFocus();
    await tester.pump();
    WindowsFocusCoordinator.nativeFocusChanged(view, true);
    expect(releases, 0);
  });
}
