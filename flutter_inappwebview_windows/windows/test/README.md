# Windows shutdown regression checks

The standalone messenger test verifies normal sends, replies, handler registration
and unregistration, repeated shutdown, and cleanup after the wrapped messenger is
destroyed. It does not instantiate WebView2 or prove native window teardown.

From the repository root, with CMake and a C++ compiler available:

    cmake -S flutter_inappwebview_windows/windows/test/shutdown_messenger -B build/shutdown_messenger -DFLUTTER_WRAPPER_INCLUDE_DIR="<Flutter app>/windows/flutter/ephemeral/cpp_client_wrapper/include"
    cmake --build build/shutdown_messenger --config Debug
    ctest --test-dir build/shutdown_messenger -C Debug --output-on-failure

Also run the Windows package's full Flutter test suite.

Manual Windows regression scenarios (under the native debugger):

- Close the app while an embedded WebView is open, both idle and loading.
- Dispose an embedded WebView while the app remains open, then create another.
- Reattach the same keepAlive WebView repeatedly; check keyboard focus, cursor,
  resizing and JavaScript calls, then exit while it remains alive.
- Dispose a keepAlive WebView explicitly, then exit.
- Exit with page-find, WebMessage or notification objects still allocated.

The plugin disables messenger forwarding before destroying any managers.
Explicit disposal while the engine runs must still unregister bridge channels.
keepAlive reattachment must clear old native callbacks while retaining the
WebView's own channel delegate.