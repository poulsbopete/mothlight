# App Store listing copy — Mothlight

Use these as starting points in App Store Connect. Adjust tone or keywords after you play the build yourself.

## App name

**Mothlight**

## Subtitle (30 characters max)

**Tap. Flap. Chase the moon.**

## Promotional text (optional, 170 chars)

New night, new record—how far can your moth fly through the pines?

## Description

Guide a tiny glowing moth through a moonlit forest with a single tap.

**Easy to play, hard to master**
- Tap anywhere to flap upward
- Slip through gaps between ancient pines
- Grab moonbeams for bonus points
- Speed ramps up as your score climbs

**Built for quick sessions**
- Portrait one-thumb play
- Instant restarts
- Personal best tracking
- Optional sound and haptics

**Support the game**
- Play for free with ads between runs
- Remove ads forever with a one-time purchase
- Optional rewarded ad to continue after a close call (once per run)

No accounts required. Just you, the forest, and the glow.

## Keywords (100 characters, comma-separated, no spaces after commas)

moth,arcade,endless,flap,tap,one touch,score,casual,retro,night,forest,moon,indie,pixel,offline

## Primary category

Games → Arcade

## Secondary category

Games → Casual

## Age rating questionnaire hints

- Cartoon/fantasy violence: None
- Horror: None
- Mature themes: None
- Gambling: None
- Unrestricted web access: No
- Advertising: Yes (third-party ads; optional reward ads)

## In-App Purchases

| Reference Name | Product ID | Type | Suggested price |
|----------------|------------|------|-----------------|
| Remove Ads | `com.mothlight.removeads` | Non-Consumable | Tier 3 ($2.99 US) |

## Privacy policy URL

Host the text from `docs/PrivacyPolicy.md` on your website (the same place you host ObservabilityBot’s policy is fine) and paste the URL into App Store Connect.

## Review notes (for App Review)

- The app uses **Google AdMob** test ad unit IDs in `GameConfig.swift` and `Info.plist` until production IDs are configured.
- **Remove Ads** is a non-consumable IAP tested with the included `Configuration/Products.storekit` file.
- App Tracking Transparency is shown before ads load when the user has not previously chosen.
- No login is required.
