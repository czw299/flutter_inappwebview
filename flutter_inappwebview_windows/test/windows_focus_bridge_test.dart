import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_windows/src/in_app_webview/custom_platform_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const manager = MethodChannel('com.pichillilorenzo/flutter_inappwebview_manager');
  const methods = MethodChannel('com.pichillilorenzo/custom_platform_view_123');
  const events = 'com.pichillilorenzo/custom_platform_view_123_events';
  final calls = <String>[];
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    calls.clear();
    messenger.setMockMethodCallHandler(manager, (call) async {
      if (call.method == 'createInAppWebView') return 123;
      return null;
    });
    messenger.setMockMethodCallHandler(methods, (call) async {
      calls.add(call.method);
      return null;
    });
    messenger.setMockMethodCallHandler(const MethodChannel(events), (_) async => null);
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(manager, null);
    messenger.setMockMethodCallHandler(methods, null);
    messenger.setMockMethodCallHandler(const MethodChannel(events), null);
  });

  Future<void> emit(String type, bool value) async {
    final done = Completer<void>();
    messenger.handlePlatformMessage(
      events,
      const StandardMethodCodec().encodeSuccessEnvelope({'type': type, 'value': value}),
      (_) => done.complete(),
    );
    await done.future;
  }

  testWidgets('native focus events return keyboard to Flutter without delayed refocus', (tester) async {
    final input = FocusNode();
    addTearDown(input.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(height: 200, child: CustomPlatformView()),
              TextField(focusNode: input),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.tapAt(const Offset(80, 80));
    await tester.pump();
    await emit('focus', true);
    expect(calls.where((e) => e == 'releaseFocus'), isEmpty);
    input.requestFocus();
    await tester.pump();
    expect(calls.where((e) => e == 'releaseFocus'), hasLength(1));
    await tester.pump(const Duration(milliseconds: 100));
    expect(input.hasFocus, isTrue);
    await emit('focus', true); // A late native grab must also yield to the input.
    await tester.pump();
    expect(calls.where((e) => e == 'releaseFocus'), hasLength(2));
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
