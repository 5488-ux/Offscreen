# Offscreen PRD

## Product

Offscreen is an AI-assisted iOS app for reducing recreational phone use. It combines Screen Time restrictions, a 30-day tapering plan, daily reflection, activity rewards, and cancellation cooldown friction.

## Core features

- AI API setup: API key, base URL, model name, and data-sharing switches.
- Screen Time summary: app-generated daily usage summary sent to AI only after consent.
- AI 30-day plan: daily entertainment allowance that gradually drops toward 15 minutes.
- Play session: user taps "Start session" when they want phone time; Offscreen checks remaining allowance, temporarily lifts restrictions, counts down, then restores restrictions.
- Whitelist: essential apps such as phone, messages, maps, payment, health, learning, and family contact tools.
- Daily 9 PM check-in: text reflection and one image, optionally reviewed by AI.
- Apple Health rewards: steps, exercise, workouts, active energy; daily reward cap should stay under 15 minutes.
- Daily 5-minute video: foreground playback only, no fast-forward credit.
- Cancellation cooldown: cancelling a 30-day plan requires 90 minutes of cumulative foreground video and a second confirmation.
- Rewards and penalties: adjust tomorrow's allowance, cancel rewards, or extend the plan.

## iOS limits

- A normal iOS app cannot kill or close other apps.
- Restrictions must use Screen Time related APIs: FamilyControls, DeviceActivity, and ManagedSettings.
- Offscreen cannot fully prevent deletion.
- Offscreen cannot fully prevent a self-use user from revoking authorization.
- AI cannot directly read phone data; it only receives app-generated summaries.
- DeviceActivity report extensions are sandboxed and cannot directly make network calls.
- This project is for self-use and is not targeting App Store release.

## MVP scope

1. AI settings screen.
2. Local 30-day plan.
3. Dashboard showing today limit, used minutes, and remaining minutes.
4. Start/stop play session state.
5. Daily check-in UI.
6. Screen Time authorization and app picker entry point.
7. HealthKit reward entry point.
8. Video watch-time tracker with placeholder bundle filenames.
9. GitHub Actions IPA pipeline.

## Later modules

- FamilyControls app picker.
- DeviceActivity monitor extension.
- ManagedSettings shield manager.
- HealthKit authorization and summary.
- AVPlayer valid-watch-time tracker.
- AI daily review and plan adjustment.
