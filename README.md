# Mothlight — iPhone endless arcade game

**Mothlight** is a one-tap endless arcade game: you guide a glowing moth through gaps in a moonlit pine forest. Tap to flap, dodge the trunks, grab moonbeams, and chase a higher score. It is built with **Swift**, **SpriteKit**, and a **SwiftUI** shell, with **StoreKit 2** (Remove Ads) and **Google AdMob** (test IDs until you ship).

You already publish [ObservabilityBot](https://apps.apple.com/us/app/observabilitybot/id6755115478), so this guide skips creating an Apple Developer account and App Store Connect basics. It focuses on **this repo**, **a new App Store record**, **IAP**, **AdMob**, **TestFlight**, and **submission**.

---

## What’s in this repo

| Path | Purpose |
|------|---------|
| `Mothlight/Mothlight.xcodeproj` | Open this in Xcode |
| `Mothlight/Mothlight/` | Game source, `Info.plist`, launch screen, privacy manifest |
| `Mothlight/Configuration/Products.storekit` | Local StoreKit testing for **Remove Ads** |
| `docs/AppStoreListing.md` | Name, subtitle, description, keywords for Connect |
| `docs/PrivacyPolicy.md` | Privacy policy text to host on your site |
| `scripts/` | Regenerates icons / Xcode project if you add Swift files |

---

## 1. Open the project on your Mac

1. Install **Xcode 15 or later** from the Mac App Store if you do not already have it.
2. Clone or download this repository.
3. Open **`Mothlight/Mothlight.xcodeproj`** (not the repo root).
4. When Xcode asks to resolve packages, click **Resolve** and wait for **Google Mobile Ads** (Swift Package Manager) to finish.

Optional: if you add `.swift` files and they do not appear in the target, run on your Mac:

```bash
python3 scripts/generate_xcodeproj.py
```

---

## 2. Signing, bundle ID, and first run

1. Select the **Mothlight** project in the navigator → **Mothlight** target → **Signing & Capabilities**.
2. Choose your **Team** (same as ObservabilityBot).
3. Set a unique **Bundle Identifier** (default in the project is `com.poulsbo.mothlight` — change it to match your naming style, e.g. `com.yourbrand.mothlight`).
4. If you change the bundle ID, update **`GameConfig.removeAdsProductID`** only if you also change the IAP product ID (see section 4).
5. Pick an **iPhone** simulator or your physical iPhone.
6. Press **Run** (⌘R).

**StoreKit while debugging:** The scheme is set to use `Configuration/Products.storekit`. You can test **Remove Ads** without App Store Connect. To verify on StoreKit Configuration: **Product → Scheme → Edit Scheme → Run → Options → StoreKit Configuration**.

**Ads while debugging:** The project uses **Google’s official test ad unit IDs** in `GameConfig.swift` and the sample `GADApplicationIdentifier` in `Info.plist`. Test on a **real device** when you can; simulators may not show real AdMob UI reliably.

---

## 3. Create the new app in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com) → **Apps** → **+** → **New App**.
2. Platform: **iOS**. Name: **Mothlight** (or your final marketing name).
3. Set **Bundle ID** to the exact identifier you use in Xcode.
4. SKU: any unique string (e.g. `mothlight-2026`).
5. User access: same as your other apps.

Use **`docs/AppStoreListing.md`** for subtitle, description, keywords, and categories. Host **`docs/PrivacyPolicy.md`** (update the contact email and domain) and add the URL under **App Privacy** and on the app’s store page.

---

## 4. In-App Purchase — Remove Ads

1. In App Store Connect → your app → **Features** → **In-App Purchases** → **+**.
2. Type: **Non-Consumable**.
3. **Reference name:** Remove Ads  
4. **Product ID:** `com.mothlight.removeads`  
   Must match `GameConfig.removeAdsProductID` in `Mothlight/Game/GameConfig.swift` and `Products.storekit`.
5. Set price (e.g. **$2.99** / Tier 3).
6. Add localization (display name **Remove Ads**, description that ads are removed forever).
7. Submit the IAP for review with the app (it stays “Waiting for Review” until the app version is submitted).

In Xcode you can keep using `Products.storekit` for local tests; for **TestFlight**, testers use **sandbox** Apple IDs as usual.

---

## 5. Google AdMob setup (production IDs)

1. [admob.google.com](https://admob.google.com) → **Apps** → **Add app** → **iOS** → link bundle ID **after** the app record exists in Connect (or register the bundle you will ship).
2. Create ad units:
   - **Interstitial** (between runs)
   - **Rewarded** (optional continue on game over)
3. Replace placeholders in **`Mothlight/Game/GameConfig.swift`**:
   - `admobAppID`
   - `admobInterstitialUnitID`
   - `admobRewardedUnitID`
4. Replace **`GADApplicationIdentifier`** in **`Mothlight/Info.plist`** with your **AdMob App ID** (format `ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy`).
5. Update **`SKAdNetworkItems`** in `Info.plist` with Google’s current list:  
   [AdMob iOS SKAdNetwork](https://developers.google.com/admob/ios/quick-start#update_your_infoplist) (merge into existing entries).

Until you replace these, the bundled **Google test IDs** are safe for development and App Review if you say so in review notes (see `docs/AppStoreListing.md`).

---

## 6. App Privacy, ATT, and privacy manifest

- **`Mothlight/PrivacyInfo.xcprivacy`** is included for required-reason APIs (UserDefaults) and declares tracking used for advertising.
- **`NSUserTrackingUsageDescription`** is in `Info.plist`. The app requests tracking via **App Tracking Transparency** before loading ads (when status is undetermined).
- In App Store Connect **App Privacy**, align labels with AdMob (identifiers for advertising, product interaction on-device). Your hosted privacy policy should match **`docs/PrivacyPolicy.md`**.

---

## 7. TestFlight

1. In Xcode: set **Version** (1.0) and **Build** (1) in the target **General** tab; bump build for each upload.
2. **Product → Archive** → **Distribute App** → **App Store Connect** → upload.
3. In Connect → **TestFlight** → add internal testers (your team) first, then external if you want.
4. Verify:
   - Play several runs; interstitial about every **3** game overs (see `GameConfig.runsBetweenInterstitials`).
   - **Remove Ads** purchase and **Restore Purchases** on menu.
   - Rewarded **continue** once per run on game over (if ad loaded).
   - Sound / haptics toggles in the in-game menu.

---

## 8. Submit for App Review

1. App Store Connect → **App Store** tab → create **1.0** version, fill metadata from `docs/AppStoreListing.md`, upload **1024×1024** icon (generated in `Assets.xcassets` or replace with final art).
2. **Age rating** — declare **advertising**; no gambling or unrestricted web.
3. Attach the **Remove Ads** IAP to the version.
4. **Review notes:** mention test AdMob IDs if production IDs are not live yet; explain ATT and IAP (template in `docs/AppStoreListing.md`).
5. Export compliance: app sets `ITSAppUsesNonExemptEncryption` to **false** in `Info.plist` (standard HTTPS only).

---

## Game design (for your reference)

- **Hook:** One-thumb flap through narrowing pine gaps; moonbeams add bonus points; speed increases with score.
- **Monetization:** Interstitials between runs; optional rewarded continue; one-time Remove Ads.
- **Game Center:** Disabled by default (`GameConfig.enableGameCenter = false`). Enable later after creating a leaderboard in Connect and updating `GameCenterManager.swift`.

---

## Building blocks you might edit

| Item | Location |
|------|----------|
| Ad frequency | `GameConfig.runsBetweenInterstitials` |
| Difficulty (gap size, speed) | `GameConfig` |
| IAP product ID | `GameConfig.removeAdsProductID` + Connect + `Products.storekit` |
| Ad unit IDs | `GameConfig.swift` + `Info.plist` |

---

## What this cloud environment did **not** do

This project was authored on **Linux** without Xcode:

- **No compile or run** on iOS Simulator or device from the cloud.
- **No AdMob** or StoreKit live verification.
- After you pull on your Mac, expect to **build once (⌘B)** and fix anything Xcode reports (often SDK renames or signing).

If the first build fails on AdMob API names, open `AdMobAdService.swift` and let Xcode offer **Fix-It** suggestions for the installed Google Mobile Ads SDK version.

---

## Quick checklist before release

- [ ] Team + bundle ID set in Xcode  
- [ ] Production AdMob app ID + ad units in `GameConfig.swift` and `Info.plist`  
- [ ] SKAdNetwork list updated for AdMob  
- [ ] IAP `com.mothlight.removeads` approved in Connect  
- [ ] Privacy policy URL live  
- [ ] App Privacy questionnaire completed  
- [ ] TestFlight pass on a physical iPhone  
- [ ] Screenshots and icon you are happy with (procedural icon is a placeholder quality — consider refreshing art)

Good luck with shipping **Mothlight**.
