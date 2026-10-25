# BUG-001 — Phone-number validation error is not exposed to accessibility services

| Field | Value |
|---|---|
| Status | **Confirmed** (reproduced repeatedly, see evidence) |
| Severity | Medium (accessibility / WCAG 4.1.3 Status Messages) |
| Priority | P2 |
| Area | Sign-up and Login → phone number entry → *Send OTP* |
| Found in | Manastik Medico 3.21.5 (build 475), `com.manastik.dadtmedico`, debug build |
| Environment | Android 14 (API 34, Google APIs, arm64) emulator, 1080×2400 @420dpi, Maestro 2.11.0 |
| Retest | Not retested (no fixed build supplied) |

## Preconditions
Fresh install / cleared data. Network available. Notification permission handled (either choice).

## Steps to reproduce
1. Launch the app → tap **Get Started** (or **Login**).
2. Tap the phone field and enter `0123456789` (10 digits, leading `0`, not a valid Indian mobile number).
3. Tap **Send OTP**.
4. Wait ~2.5 s. A red toast "Please enter a valid phone number." appears at the top for ~2 s.
5. Inspect the accessibility tree while the toast is on screen (Maestro `hierarchy`, `uiautomator dump`, or enable TalkBack).

## Expected
The message text is present in the accessibility tree / announced as a live region, so TalkBack users
and UI automation can detect the error.

## Actual
The toast is visible on screen (confirmed by pixel sampling of its red error icon during the same
window), but its text never appears in the accessibility tree. Maestro
`extendedWaitUntil: visible: "Please enter a valid phone number."` with a 12 s timeout fails, while the toast
is on screen for part of that window. Screen-reader users get no feedback after tapping *Send OTP*.

## Evidence
- `evidence/screenshots/BUG-001_toast_visible_on_screen.png` — toast visible on screen.
- `tests/maestro/flows/10_bug001_validation_toast_accessible.yaml` — automated repro, **fails by design**
  (run: `maestro test tests/maestro/flows/10_bug001_validation_toast_accessible.yaml`).
- `evidence/runs/bug001/` — Maestro run artifacts (failure screenshot, hierarchy dump, logs).

## Notes / limits
- Not verified with a real TalkBack session (emulator only) — the claim is limited to what the
  accessibility tree exposes, which is what TalkBack consumes.
- Secondary observation (not filed as a bug): the error appears ~2.3–2.8 s after the tap, which suggests
  the number is validated server-side after a round-trip rather than on the client, so users get no
  immediate feedback and the *Send OTP* button looks enabled for any 10 digits. Treat as a UX suggestion.
