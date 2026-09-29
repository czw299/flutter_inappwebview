# MindMapFlutter fork maintenance

- Fork: https://github.com/czw299/flutter_inappwebview
- Maintenance branch: `minder-6.2.0-beta.3`
- Exact upstream baseline: `5e4b6a4cd88870a45c8e2396bb43ce94a50e7317` (6.2.0-beta.3).
- The upstream `v6.2.0-beta.3` tag has an identical source tree.

## Imported local patches

- Android: remove bitmap decoding for unused native toolbar/browser icons and the default video poster. These are the existing application patches, imported without additional behavior changes.
- Windows: preserve the shared native resource lifetime and process-exit workaround from the application's patched InAppWebViewManager. Related upstream PR: https://github.com/pichillilorenzo/flutter_inappwebview/pull/2838.
- Package manifests: retain relative sibling dependencies so all platform backends and the platform interface resolve from this checkout. Point repository and issue links to this fork.

The Windows patch does not claim to solve every shutdown hang. Focus changes and further shutdown improvements are intentionally outside this baseline commit.

Applications should pin the Git dependency to an exact commit and use the `flutter_inappwebview` subdirectory. Make future plugin changes here and update the application's pinned revision after validation; do not maintain a second set of copied patch files in the application repository.
## Windows focus port

The inline texture host now reparents WebView2 input windows to the Flutter view, coordinates native focus with Flutter text input and pointer hit testing, and handles Tab traversal out of the page. The previous delayed refocus retry is removed.

The original composition HWND is tracked separately for destruction. Bounds are relative to Flutter's client area; positioning no longer moves the controller's parent window. New native callbacks are removed before bridge destruction, including kept-alive views. Existing shared-resource shutdown patches are unchanged.

Source inspiration: omar-hanafy/webview_flutter_windows at fa4ee153a2cf998400d8a23a58c1f63ee4ba41c3. Attribution and BSD license are included in the Windows package.

Validation: Windows package focus coordinator and mocked widget/channel regression tests. Real WebView2 focus, IME, popup placement, DPI, multi-window behavior and application shutdown still require device verification.