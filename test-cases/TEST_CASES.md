# Test Cases

Legend — **Status:** `PASS`/`FAIL` = executed by Maestro (results: `docs/EXECUTION_SUMMARY.md`);
`MANUAL` = executed exploratorily only; `NOT RUN` = not executed (reason given). Priority P1 (critical) … P3 (low).
Cases marked *proposed* describe expectations that were **not** verified against the app.

Scope covered: Welcome → Sign-up/Login → phone OTP → 7-stage onboarding (personal details + email OTP,
role, qualifications and registration document upload, experience, specialisation, institute, practice
configuration) → *Verification in progress*.

## A. Automated (Maestro) — executed, 2 consecutive full runs all green

| ID | Flow | Objective | Preconditions | Steps | Expected | Actual (verified) | Pri | Status |
|---|---|---|---|---|---|---|---|---|
| TC-WEL-01 | `01_welcome_screen` | Welcome screen renders on fresh install | Data cleared | Launch, accept notification prompt | Headline, "TRUSTED BY…", Login + Get Started | As expected | P1 | PASS |
| TC-PRM-01 | `02_notification_permission_denied` | App usable when notifications denied | Permissions unset | Launch, *Don't allow*, Get Started | Welcome shown, sign-up reachable | As expected | P1 | PASS |
| TC-SUP-02 | `03_signup_phone_input_rules` | Digits only, max 10 | On sign-up | Type letters; type 11 digits | Letters ignored; first 10 kept | As expected | P2 | PASS |
| TC-SUP-03 | `04_signup_invalid_phone_rejected` | Invalid/incomplete numbers don't advance | On sign-up | Empty; 9 digits; `0123456789` | No navigation | No navigation; toast shown (screenshot) – see BUG-001 | P1 | PASS |
| TC-LOG-02 | `05_login_invalid_phone_rejected` | Login rejects invalid numbers | On login | Empty; 5 digits; `1234567890` | Stays on Login | As expected | P1 | PASS |
| TC-NAV-01 | `06_signup_login_navigation` | Sign-up ↔ Login, system Back | Welcome | Get Started → LOG IN → CREATE ACCOUNT → Back ×2 | Correct screens; Back returns to Welcome | As expected | P2 | PASS |
| TC-INT-01 | `07_state_survives_backgrounding` | Typed number survives Home/resume | Number typed | Home, reopen | Same screen and value | As expected | P2 | PASS |
| TC-NET-01 | `08_signup_offline_error` | Offline *Send OTP* recovery | Airplane mode on | Send OTP; Try Again | "Network Error" + *Try Again*; stays after retry | As expected | P1 | PASS |
| **TC-E2E-01** | `09_e2e_signup_to_verification_pending` | **Complete onboarding happy path** | Fresh app; test OTP; fresh phone+email | Phone OTP → Stage 1 form + email OTP → role → degree + registration PDF upload → resume upload → achievements (optional) → specialisation → institute search/select → Stage 7 required-field errors, then fill (language, type, procedure, fee, availability) → Publish → Complete | Ends on *Verification in progress*; relaunch resumes there | As expected, incl. 5 inline required-field messages and numeric-only fee | P1 | PASS |
| TC-OTP-02 | `11_otp_wrong_code_then_recover` | Wrong phone OTP | On OTP screen | Enter `000000`; refocus, clear, enter correct code | Inline "Invalid security code" (red boxes); recovery works | As expected | P1 | PASS |
| TC-REG-02 | `12_stage1_form_validation` | Stage 1 validation | On Stage 1 | Next while empty; invalid email `abc`; Next with invalid email | Inline "Please enter a valid email address"; no advance | As expected | P1 | PASS |
| TC-LOG-01 | `13_login_existing_account` | Login resumes pending account | Account that finished TC-E2E-01 | Login → phone → OTP | Lands on *Verification in progress* | As expected | P1 | PASS |
| BUG-001 | `10_bug001_validation_toast_accessible` | Toast text in accessibility tree | — | Send OTP with `0123456789` | Text visible to Maestro/TalkBack | Not exposed | P2 | FAIL (defect confirmed; excluded from default run) |

## B. Exploratory (manual, verified)

| ID | Observation |
|---|---|
| EX-01 | *Send OTP* is grey until 10 digits; at 10 digits it is enabled **regardless of validity**. Invalid numbers are rejected after the tap (toast ≈2.5 s later), not inline. |
| EX-02 | Phone OTP validates automatically at 6 digits; email OTP needs an explicit *Confirm*. |
| EX-03 | After a wrong phone OTP the boxes lose focus; the user must tap them to correct (delete clears all digits). |
| EX-04 | The correct test code was rejected once, after a prior wrong attempt **and** ~2 minutes after the code was requested; entered promptly on a fresh request it is accepted. The two causes (attempt counter vs. expiry) were not separated, so nothing was filed. |
| EX-05 | Primary-degree and registration uploads are **PDF-only** (PNG is disabled in the picker); the resume upload accepts PNG as its label states. |
| EX-06 | Stage 6 institute search returns live places data (e.g. "Apollo" → real hospital addresses) and offers *Add new institution*. |
| EX-07 | Selected institute is added with the default role "Senior Consultant" without the user choosing it. |
| EX-08 | System Back on *Verification in progress* leaves the app; relaunch returns to that screen. There is no sign-out/exit action on it. |
| EX-09 | Notification permission is requested again on every cold start while it is not granted. |

## C. Proposed / not executed

| ID | Objective | Proposed expectation | Pri | Status / reason |
|---|---|---|---|---|
| TC-OTP-03 | Expired OTP and *Resend Code* | Old code rejected, new code accepted, resend throttled | P2 | NOT RUN — needs waiting out timers; only observed informally (EX-04) |
| TC-OTP-05 | Repeated wrong OTPs | Rate limit / lock-out message | P2 | NOT RUN — would hammer the shared test backend |
| TC-LOG-03 | Login with an unregistered number | "Not registered" message | P2 | NOT RUN — behaviour unknown; risked creating/notifying real numbers |
| TC-REG-03 | Duplicate email / phone sign-up | Clear "already registered" message | P2 | NOT RUN |
| TC-REG-04 | Stage 1 boundaries (future/under-age DOB, very long names, emoji) | Rejected with messages | P2 | NOT RUN |
| TC-UPL-02 | Large / corrupt / wrong-type document upload | Size/type error, retry possible | P2 | NOT RUN (only the PDF-only picker filter observed) |
| TC-VER-02 | Identity verification **outcome** (approved / rejected) | Notification and state change after review | P1 | NOT RUN — the review is a human process "up to 24 hours"; only the *pending* state is testable |
| TC-A11Y-01 | TalkBack walkthrough | All controls labelled and announced | P2 | NOT RUN — emulator tree checked only (BUG-001) |
| TC-DEV-01 | Rotation, small screens, dark mode, low memory | Layout intact, state kept | P3 | NOT RUN |
