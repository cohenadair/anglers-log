# Screenshots

Everything for Anglers' Log's App Store / Google Play screenshots. Both
folders are configuration for shared workspace tools; neither tool lives
here.

| Folder | Used by | What's in it |
| --- | --- | --- |
| [`assets/`](assets) | [`screenshots/studio`](../../screenshots/studio) | The slide deck (`app-store-screenshots.json`) and the raw device screenshots it uses. |
| [`capture/`](capture) | [`screenshots/capture`](../../screenshots/capture) | Seed data, screens, and the app-side entrypoint used to capture those raw screenshots automatically. |

The usual flow:

1. Edit the seed data or screens in `capture/` (see its README).
2. Capture: `dart run bin/capture.dart anglers-log` from `screenshots/capture`
   (or ask Claude to run the `capture-store-screenshots` skill). New
   screenshots land in `assets/screenshots/`.
3. Open the screenshots studio, pick Anglers' Log, and export.
