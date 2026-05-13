# TallyBar — Mac App Store submission checklist

Everything in **bold** is your action. Everything not bold is already wired up in this repo.

## 0. Before you start

Required: Apple Developer Program membership (✓ you have this), Xcode 15+, a Mac running macOS 13+.

## 1. Register the bundle ID

1. **Go to <https://developer.apple.com/account/resources/identifiers/list>.**
2. **Click + → App IDs → App → Continue.**
3. **Description:** TallyBar — Word & Character Counter
4. **Bundle ID:** Explicit, value `com.johnnybabcock.TallyBar` (must match `BUNDLE_ID` in `Scripts/build-app.sh`).
5. **Capabilities:** none needed. Continue → Register.

> If you own a domain (e.g. `tallybar.app`), use `app.tallybar.TallyBar` instead — domain-style bundle IDs are conventional. Update `BUNDLE_ID` in `Scripts/build-app.sh` to match if you do.

## 2. Create the App Store Connect record

1. **Go to <https://appstoreconnect.apple.com/apps>, click + → New App.**
2. **Platform:** macOS.
3. **Name:** `TallyBar — Word & Character Counter` (30-char limit; this is the ASO-critical field).
4. **Primary Language:** English (U.S.).
5. **Bundle ID:** select the one you just registered.
6. **SKU:** anything stable, e.g. `tallybar-mac-001`.
7. **User Access:** Full Access.

## 3. App Store listing fields

Fill these in App Store Connect → your app → App Store tab → 1.0 Prepare for Submission.

| Field | Value |
|---|---|
| **Subtitle** (30 chars) | `Clipboard character count` |
| **Promotional Text** (170 chars) | `See your clipboard's word, character, and line count live in the menu bar. 100% local — no network, no tracking, no data collection.` |
| **Description** | See `App Store/description.txt` |
| **Keywords** (100 chars) | `wordcount,character,count,clipboard,writer,tweet,essay,limit,menubar,length,paste,counter` |
| **Support URL** | `https://johnnybabcock.github.io/tallybar/support` |
| **Marketing URL** (optional) | `https://johnnybabcock.github.io/tallybar/` |
| **Privacy Policy URL** | `https://johnnybabcock.github.io/tallybar/privacy` |
| **Category — Primary** | Productivity |
| **Category — Secondary** | Utilities |
| **Copyright** | `2026 John Babcock` |

## 4. Pricing & Availability

- **Price:** Free (Tier 0).
- **Availability:** All territories (or restrict if you have a reason).
- **Pre-order:** off.

## 5. App Privacy questionnaire

App Store Connect → your app → **App Privacy** → "Get Started".

Answer **"No, we do not collect data from this app."** That's the truthful answer — clipboard contents are read in-memory and discarded.

## 6. Age Rating

- All categories: **None**.
- Final rating: **4+**.

## 7. App Review Information

This is what saves you from the rejection that killed the original Bar Counter.

- **Sign-in required:** No.
- **Demo account:** N/A.
- **Notes:**

  > TallyBar is a macOS menu bar utility that counts characters, words, and lines from the user's clipboard and displays the count in the menu bar.
  >
  > Clipboard contents are read with `NSPasteboard.general.string(forType:)` only when `NSPasteboard.general.changeCount` increments. The polling interval is 400 ms. macOS provides no event-driven pasteboard change API; polling is the only available approach.
  >
  > Clipboard contents are read into memory, counted, and never persisted, transmitted, logged, or shared. The app has no network code, no analytics, and no third-party SDKs. App sandbox is enabled. The privacy manifest declares zero data collection.
  >
  > A privacy policy is published at https://johnnybabcock.github.io/tallybar/privacy.

- **Contact info:** your email and phone.

## 8. Assets

You still need:

- **App icon** — 1024×1024 PNG, no transparency, no rounded corners (the OS rounds them). Place in App Store Connect listing.
- **Screenshots** — at least one, up to ten, in one consistent size from this list: 1280×800, 1440×900, 2560×1600, 2880×1800. I recommend 2880×1800 (Retina). Three to five shots:
  1. Menu bar showing the live count above some text being copied.
  2. Dropdown menu open showing all four metrics.
  3. "Display in menu bar" submenu open.
  4. "Launch at login" toggle on.
  5. (Optional) "Shorten label" comparison.
- **App preview video** — optional; skip for v1.

Capture screenshots with **Cmd-Shift-5** at Retina resolution. Edit/resize in Preview or Acorn.

## 9. Build & upload

Two options. **Option B is recommended** for App Store submissions.

### Option A — Pure SwiftPM (Developer ID outside-store distribution)

```sh
SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" \
ENABLE_SANDBOX=1 \
UNIVERSAL=1 \
./Scripts/build-app.sh
```

This produces `build/TallyBar.app` signed for outside-store distribution. For notarization:

```sh
xcrun notarytool submit build/TallyBar.app --apple-id you@example.com --team-id TEAMID --wait
xcrun stapler staple build/TallyBar.app
```

### Option B — Xcode (Mac App Store)

The App Store requires signing with the App Store distribution certificate and uploading via Xcode Organizer or `xcrun altool`. Easiest path:

1. **Open Xcode → File → New → Project → macOS → App.** Name it `TallyBar`, organization identifier `com.johnnybabcock`, language Swift, interface SwiftUI.
2. **Delete the generated `ContentView.swift` and `TallyBarApp.swift`.** Drag `Sources/TallyBar/*.swift` into the project (uncheck "copy if needed" so the files stay in source control here).
3. **In Project Settings → Signing & Capabilities:**
   - Check "Automatically manage signing".
   - Team: your Apple Developer team.
   - Add Capability: **App Sandbox** (no extra checkboxes needed).
   - Bundle Identifier: `com.johnnybabcock.TallyBar`.
4. **Drag `Resources/PrivacyInfo.xcprivacy` into the project**, check "Copy items if needed", target membership = TallyBar.
5. **Set Info.plist values:**
   - `LSUIElement` = YES (Application is agent — no Dock icon).
   - `LSMinimumSystemVersion` = `13.0`.
6. **Product → Archive.**
7. **Organizer window → Distribute App → App Store Connect → Upload → Next → Automatically manage signing → Upload.**

The build appears in App Store Connect → your app → TestFlight tab after Apple processes it (~10-30 min). Then in the 1.0 Prepare for Submission screen, select the build under "Build".

## 10. Submit for review

In App Store Connect, click **Add for Review → Submit for Review**.

Expected timeline: 24-48 hours for first review. If rejected, the rejection notice will cite a guideline. The most likely one for clipboard-reading apps is 5.1.1 (Data Collection and Storage). Reply citing the App Review notes above — emphasize on-device only, no network, sandboxed, privacy manifest declares zero collection.

## 11. After approval

- Promote on Hacker News (Show HN), r/macapps, MacStories tips line (tips@macstories.net).
- Ask 3-5 writer friends to leave honest reviews in the first week. Initial review velocity is the biggest discoverability signal.
- Watch for "App Store search" share of installs in App Store Connect → Analytics → Sources after a week. Iterate on keywords if needed (the field is editable without resubmission… actually, no: changing keywords requires a new app version. The Promotional Text field is updatable anytime — use it for launch announcements).
