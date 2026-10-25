# BUG-003 — "Languages Spoken" does not get the error border other invalid fields get

| Field | Value |
|---|---|
| Status | **Confirmed** (screenshot) |
| Severity | Low (visual inconsistency) |
| Priority | P3 |
| Area | Onboarding Stage 7 – practice details form |
| Found in | Manastik Medico 3.21.5 (build 475), debug build |
| Environment | Android 14 (API 34) emulator |
| Retest | Not retested |

## Preconditions
Reach Stage 7, add an institute, open its configuration form (see `flows/09_e2e_signup_to_verification_pending.yaml`).

## Steps
1. Leave all fields empty and tap **Next**.

## Expected
All five required fields get the same invalid styling (red border) plus their message.

## Actual
All five messages appear ("Please select language spoken", "…consultation type", "…specialized procedures",
"…consultation fee", "…availability timings"), and four fields get a red border. **Languages Spoken keeps its
normal grey border**, so the error text under it looks detached from the field.

## Evidence
`evidence/screenshots/BUG-003_languages_field_no_error_border.png`
(The messages themselves are exposed in the accessibility tree — unlike BUG-001 — and are asserted in TC-E2E-01.)
