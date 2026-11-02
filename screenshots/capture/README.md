# Screenshot capture

Anglers' Log's configuration for the shared
[`screenshots/capture`](../../../screenshots/capture) tool, which seeds the
app, drives it to each screen on iOS simulators and Android emulators, and
saves the screenshots to [`../assets`](../assets). See that tool's README for
how a run works and the `capture.json` format.

| File | What it is |
| --- | --- |
| `seed/seed.json` | English seed data. **The source of truth; edit this.** |
| `seed/translations/es.json` | English → Spanish for every user-visible seed string. |
| `seed/photos/` | Photos referenced by the seed (see below). |
| `capture.json` | Devices, locales, the screens that can be captured, and which screen each file (`01.png`, ...) is. |
| `build_seed.dart` | The seed command: validates the seed and converts it to protobuf database rows. Generic parts (timestamps, translations, photos, the CLI) come from `package:screenshots_capture/seed.dart`. |
| `capture_app.dart` | The app-side entrypoint: loads the seed into the database and shows each screen. |
| `seed_ids.dart` | Seed key → UUID, shared by both. |

No app code is involved: `capture_app.dart` seeds the database through the
app's own `openDb()` before launching `AnglersLog`, and Pro is enabled by
swapping `SubscriptionManager` for a stub.

To check the seed (missing translations or photos, invalid fields) without
capturing anything:

```bash
dart run build_seed.dart --check
```

Until the photos are in place, capture with stand-ins by passing
`-- --placeholder-photos` to `screenshots/capture`.

## Seed format

`seed.json` is proto3 JSON (the same field names as `anglers_log.proto`, in
lowerCamelCase), plus a few conveniences that `build_seed.dart` expands:

- **Keys instead of IDs.** Every entity has a unique `"key"`. Reference other
  entities by key in any `...Id` / `...Ids` field, e.g.
  `"speciesIds": ["walleye"]`, `"baits": [{"baitId": "stick_worm", "variantId": "stick_worm_watermelon"}]`.
  Keys are global across collections and become stable UUIDs.
- **Relative timestamps.** `"-3d 06:42"` is 6:42 AM three days before the run,
  in the seed's `timeZone`, so the calendar and "recent" data never go stale.
  `"0d 05:30"` is today, so keep today's times early in the morning.
  ISO-8601 dates also work, read in the seed's `timeZone` unless they have an
  offset.
- **Measurements.** `"24.5 in"`, `"5 lb 4 oz"`, `"54 F"`, `"14 ft"`, `"8 mph"`,
  `"30 cm"`, etc., in any MultiMeasurement field (length, weight, water depth
  and temperature, atmosphere values, rod length, ...).
- **Photos.** `imageName` / `imageNames` take a file name *without* extension
  from `seed/photos/` (`.jpg`, `.jpeg`, `.png`, `.heic` or `.webp`).
- **GPS trail points** are `[lat, lng]` pairs, spread evenly between the
  trail's start and end timestamps.
- **Preferences** (`"preferences"`) are written as-is to the `user_preference`
  table (see `UserPreferenceManager` for keys). Seed keys in values or map keys
  become UUIDs, and `"now"` becomes the current timestamp. Onboarding, the
  change log, and the translation warning are skipped automatically.

Translated fields are `name`, `notes`, `description` and `color`. Every
distinct English value needs an entry in each translation file. Names that
also appear on the map (e.g. "Silver Lake") stay the same in every language,
since map labels aren't translated.

The fishing spots and GPS trail are around Silver Lake, near
`capture.json` → `deviceLocation`, so the app's names match the map's labels.

## Photos

The seed references these photos, which must be added to `seed/photos/`
before a real run (`--check` lists any that are missing):

- Catches: `catch-walleye-1`, `catch-walleye-2`, `catch-perch-1`,
  `catch-smallmouth-1`, `catch-largemouth-1`, `catch-largemouth-2`,
  `catch-pike-1`, `catch-pike-2`, `catch-muskie-1`, `catch-crappie-1`,
  `catch-trout-1`, `catch-catfish-1`
- Baits: `bait-crankbait`, `bait-stick-worm`, `bait-spinner`, `bait-jig`
- Fishing spots: `spot-north-bay`, `spot-bridge-pool`

## Screens

`capture.json` → `screens` names each screen and its parameters:

| `screen` | Parameters | Shows |
| --- | --- | --- |
| `catch_list` | | Catches tab |
| `catch_details` | `catch` (seed key) | A catch's page |
| `fishing_spot_map` | `bounds`: `[[south, west], [north, east]]` | Map tab, fitted to `bounds` |
| `report` | `report`: `personal_bests` or `catch_summary` | Stats tab with that report |
| `calendar` | | Calendar page, on today |
| `gps_trail` | `gpsTrail` (seed key) | A GPS trail's page |
| `species_counter` | | Species counter |

Screens are captured in dark mode. Any screen also accepts
`"theme": "light"` and `"delaySeconds"` (time to wait after the screen settles, before capturing; default 1, longer for maps and
catch pages so tiles and map images load on a fresh install). New screens are added to `_AnglersLogCapture.show()` in
`capture_app.dart`.

`captures` maps each device's file names to a screen. iPhone and iPad `02`
is the deck's "Light & dark themes" slide, so it's captured in light mode.
The Android decks have no dark slide (Google Play allows 8 screenshots).
