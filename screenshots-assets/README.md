# App Store Screenshots — Assets

This folder holds **Anglers' Log**'s project config and raw screenshots for
the shared [`screenshots`](../../screenshots) tool — the
editor used to design and export App Store / Google Play marketing
screenshots.

It is data, not code: `app-store-screenshots.json` (created the first time
this project is saved in the editor) is this project's slide deck (copy,
layout, theme), and `screenshots/` holds the raw device captures it
references. Editing screenshots for this app happens in the shared tool's
editor, not by hand-editing files here.

To work on this project's screenshots:

1. From the `screenshots` repo, run the dev server (see its
   README for setup).
2. Open the editor and select **Anglers' Log** from the project picker.

The tool itself — including any bug fixes, layout changes, or new device
support — lives entirely in the `screenshots` repo, not here.
