// Adapted from webview_flutter_windows's focus coordination strategy.
// See THIRD_PARTY_NOTICES for source and license.
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class WindowsWebViewFocusHandle {
  WindowsWebViewFocusHandle({required this.release});
  final Future<void> Function() release;
  bool hasNativeFocus = false;
}

/// Coordinates only mounted inline views in this Flutter isolate.
class WindowsFocusCoordinator {
  static final _views = <WindowsWebViewFocusHandle>{};
  static final _claimedPointers = <int>{};

  static void register(WindowsWebViewFocusHandle view) {
    if (!_views.add(view) || _views.length != 1) return;
    GestureBinding.instance.pointerRouter.addGlobalRoute(_pointer);
    FocusManager.instance.addListener(_flutterFocusChanged);
  }

  static void unregister(WindowsWebViewFocusHandle view) {
    _views.remove(view);
    view.hasNativeFocus = false;
    if (_views.isNotEmpty) return;
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_pointer);
    FocusManager.instance.removeListener(_flutterFocusChanged);
    _claimedPointers.clear();
  }

  static void claimPointer(int pointer) => _claimedPointers.add(pointer);

  static void nativeFocusChanged(WindowsWebViewFocusHandle view, bool focused) {
    if (!_views.contains(view)) return;
    view.hasNativeFocus = focused;
    if (focused) _flutterFocusChanged();
  }

  static void _pointer(PointerEvent event) {
    if (event is! PointerDownEvent) return;
    // Local hit-test listeners run before the global pointer route, so overlays
    // and IgnorePointer/AbsorbPointer correctly count as Flutter interaction.
    if (_claimedPointers.remove(event.pointer)) return;
    _release();
  }

  static void _flutterFocusChanged() {
    final context = FocusManager.instance.primaryFocus?.context;
    if (context?.findAncestorStateOfType<EditableTextState>() != null) _release();
  }

  static void _release() {
    for (final view in _views.toList()) {
      if (view.hasNativeFocus) {
        view.hasNativeFocus = false;
        unawaited(view.release());
      }
    }
  }
}
