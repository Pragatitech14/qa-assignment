# Execution summary

Environment: see `ENVIRONMENT.md` (Android 14 arm64 emulator, Maestro 2.11.0, app 3.21.5 build 475).
Everything below comes from real runs; raw console output is in `evidence/logs/`, per-run artifacts in `evidence/runs/`.

## Final result
| Run | Flows (default suite) | TC-LOG-01 (existing account) | Duration |
|---|---|---|---|
| `run1` | **11 / 11 passed** | passed | 12 m 32 s |
| `run2` | **11 / 11 passed** | passed | 12 m 24 s |

* BUG-001 repro (`10_bug001_…`) was run once in `run1` and **fails by design** (defect confirmed).
* Reliability: 2 consecutive complete runs, each starting every flow from wiped app data. Each run creates a fresh
  account (random phone + email), so runs do not interfere. Two runs is a small sample, not a flakiness guarantee.
* Total flows in repo: 13 (11 default + TC-LOG-01 + BUG-001 repro).

## Per-flow results (run1 / run2)
| Test case | Flow | run1 | run2 |
|---|---|---|---|
| TC-WEL-01 Welcome screen | 01 | pass 29 s | pass 31 s |
| TC-PRM-01 Notification permission denied | 02 | pass 24 s | pass 24 s |
| TC-SUP-02 Phone input rules (digits only, 10 max) | 03 | pass 38 s | pass 38 s |
| TC-SUP-03 Invalid/incomplete phone rejected | 04 | pass 61 s | pass 52 s |
| TC-LOG-02 Login rejects invalid phone | 05 | pass 51 s | pass 51 s |
| TC-NAV-01 Navigation + Back | 06 | pass 44 s | pass 44 s |
| TC-INT-01 State survives backgrounding | 07 | pass 46 s | pass 46 s |
| TC-NET-01 Offline → Network Error + Try Again | 08 | pass 43 s | pass 44 s |
| **TC-E2E-01 Full onboarding → Verification in progress (+ relaunch)** | 09 | pass 4 m 40 s | pass 4 m 41 s |
| TC-OTP-02 Wrong OTP rejected inline + recovery | 11 | pass 55 s | pass 55 s |
| TC-REG-02 Stage 1 form validation | 12 | pass 79 s | pass 78 s |
| TC-LOG-01 Login with existing account | 13 | pass 47 s | pass 48 s |

## History of automation defects found and fixed (not app bugs)
| # | Symptom | Root cause | Fix |
|---|---|---|---|
| 1 | Notification dialog never shown | Maestro `launchApp` grants all permissions by default | `permissions: all: unset` |
| 2 | Phone field not found | Flutter exposes a multi-line hint | selector `Phone Number.*` |
| 3 | Flow fell back to Welcome mid-test | `hideKeyboard` sent a system Back when the keyboard was already closed | removed the call |
| 4 | Flows failed at launch step | Dialog can take >10 s after cold start; sometimes suppressed | 25 s optional wait + optional tap |
| 5 | Twice during development a fresh launch landed on a stale Login screen (once inside the earlier 3-run batch: `evidence/logs/suite_runs_before_launch_hardening.log`, run3, TC-NAV-01) | Not reproducible on demand; suspected restored task state | detect and relaunch once in `launch_fresh` |
| 6 | Document picker taps ignored | PNG in picker is disabled for PDF-only slots; regex matched it first | exact file name |
| 7 | Picker drawer closed instead of opening Downloads | Tap during drawer animation | `waitForAnimationToEnd` + retry |
| 8 | Next tap ignored after a selection | Tap during selection animation | settle wait + retry guard |
| 9 | Re-run collisions | Reused phone/email already registered | random phone + email per run |

## Confirmed application defects
| ID | Severity | Summary |
|---|---|---|
| BUG-001 | Medium | Phone-number validation toast text is not exposed to accessibility services |
| BUG-002 | Low | Wrong / unpolished headings on Stages 2, 5, 7 |
| BUG-003 | Low | "Languages Spoken" missing error border |

## Not covered
See README "Known limitations" and `test-cases/TEST_CASES.md` section D (BLOCKED / not executed).
