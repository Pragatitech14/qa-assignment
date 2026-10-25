# Test Plan — Manastik Medico onboarding (QA track)

## 1. Scope decision (assignment ambiguity)
`QA_Assignment.pdf` mixes three things: (a) the QA-track brief ("test the Android app supplied by the hiring
team… automate the complete onboarding workflow — from sign-up through identity/account verification"),
(b) the Flutter-track product requirements (posture tracker) and (c) an appendix about a physiotherapy
exercise tracker that is explicitly marked *"Only QA track applicants can ignore this"*.

The supplied APK is **Manastik Medico** (`com.manastik.dadtmedico`, v3.21.5 build 475): a phone-number/OTP
account app. No camera/posture/exercise UI is reachable before sign-in. Therefore **scope = (a)**: automated
end-to-end onboarding QA of the supplied APK. (b)/(c) were not tested.

## 2. Objectives
1. Verify the sign-up/login entry funnel (welcome → phone number → OTP request).
2. Cover input validation, negative, boundary, permission, interruption and network-failure behaviour.
3. Provide repeatable Maestro automation and evidence; report defects honestly.

## 3. Out of scope / blocked
| Item | Reason |
|---|---|
| OTP verification, account creation, identity verification screens | **No test credentials / OTP were supplied** (the PDF says they "will be provided"). The OTP goes by SMS to a real number; sending requests for real numbers was deliberately avoided. Cases are written (TC-E2E-*) but **not executed**. |
| Post-login features | Same blocker. |
| iOS, tablets, low-end hardware, real camera | Not available / not applicable to the supplied pre-login flow. |
| Performance, security, penetration testing | Outside assignment; no authorization for security testing. |

## 4. Test environment
| Item | Value |
|---|---|
| App under test | `app-debug.apk` (252 MB, debug build, Flutter) — SHA-256 in `docs/ENVIRONMENT.md` |
| Device | Android Emulator `qa_pixel`: Android 14 (API 34) Google APIs, arm64-v8a, 1080×2400 @420 dpi, 4 GB RAM, on Apple-silicon macOS |
| Automation | Maestro 2.11.0, OpenJDK 17, Android SDK platform-tools 37 / emulator 37.2.12 |
| Network | Host Wi-Fi via emulator NAT; airplane mode toggled by Maestro for offline tests |

## 5. Approach
* **Exploratory pass** on the real app (screens, selectors, validation, timing) to derive cases and verified selectors.
* **Scripted Maestro flows** (`tests/maestro/flows`) using Flutter accessibility labels; each flow starts from a wiped app
  (`clearState`) so flows are order-independent.
* Evidence: Maestro per-step screenshots, hierarchies, logs and JUnit XML per run under `evidence/runs/`.
* Reliability: the full suite was run three consecutive times (results in `docs/EXECUTION_SUMMARY.md`).

## 6. Risks & mitigations
| Risk | Mitigation |
|---|---|
| Flutter text is only in accessibility labels | Selectors use label regexes; verified against real hierarchy dumps |
| Overlays/toasts not in the tree (BUG-001) | Evidence by screenshot; assertions on stable outcomes |
| Android suppresses notification prompt after repeated denial | Optional-wait in shared launch subflow; strict check in TC-PRM-01 |
| SMS side effects on real numbers | Only impossible numbers (`0…`, `1…`) or offline mode used when pressing *Send OTP* |

## 7. Exit criteria
All executed flows pass or have a filed defect; blocked cases listed with the unblock action (test number + OTP).
