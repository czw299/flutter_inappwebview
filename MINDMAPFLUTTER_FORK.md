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