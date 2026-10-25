# BUG-002 — Onboarding screens show wrong / unpolished heading text

| Field | Value |
|---|---|
| Status | **Confirmed** (visible in screenshots, reproduced twice) |
| Severity | Low (cosmetic / copy) |
| Priority | P3 |
| Area | Onboarding Stages 2 (Professional role), 5 (Specialisation) and 7 (Practice details) |
| Found in | Manastik Medico 3.21.5 (build 475), debug build |
| Environment | Android 14 (API 34) emulator, 1080×2400 @420 dpi |
| Retest | Not retested (no fixed build supplied) |

## Steps to reproduce
1. Fresh install → Get Started → complete phone OTP, Stage 1 form, email OTP.
2. **Stage 2 – Professional role:** observe the subtitle under "Select Professional Role".
3. Tap *Medical*. Observe the heading of the role list.
4. Continue to **Stage 5 – Professional specialisation** and observe the heading.

## Expected
Headings and subtitles describe the current step (e.g. subtitle "Choose the role that best describes you";
sentence-case heading such as "Select your role" / "Choose your specialisation").

## Actual
| Screen | Text shown | Problem |
|---|---|---|
| Stage 2 | Subtitle: "Please enter your personal details" | Copied from Stage 1; the screen asks for a role, not personal details |
| Stage 2 (after *Medical*) | Heading: "Select Enhanced User Role Selection" | Reads like an internal/feature-flag name, redundant wording |
| Stage 5 | Heading: "PROFESSIONAL SPECIALISATION" (all caps, duplicates the stage label above it) | Inconsistent with every other screen |
| Stage 7 | Hospital address "…500096, India, Hyderabad, Telangana" | City/state appended after an address that already contains them (duplicate) |

## Evidence
`evidence/screenshots/BUG-002_stage2_wrong_subtitle.png`, `BUG-002_stage2_internal_style_heading.png`,
`BUG-002_stage5_all_caps_heading.png`, `exploration_stage7_form.png`.
