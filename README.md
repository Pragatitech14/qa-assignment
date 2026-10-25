# Manastik Medico — QA Engineer Assignment (Maestro automation)

Track: **B — QA Engineer.** App under test: the supplied `app-debug.apk` (**Manastik Medico**, `com.manastik.dadtmedico` v3.21.5 / build 475).

> **Status:** the full onboarding — Welcome → phone OTP → 7-stage profile (email OTP, role, document uploads,
> specialisation, institute, practice configuration) → *Verification in progress* — is automated end to end with Maestro.
> 11 flows + 1 existing-account login pass on two consecutive full runs; 3 defects are confirmed
> (BUG-001 medium, BUG-002/003 low). The *outcome* of identity verification (a human review "within 24 hours")
> cannot be tested; only the pending state is. See [Known limitations](#known-limitations).

## What is in here
```
README.md
test-cases/TEST_PLAN.md       scope decision, environment, approach, risks
test-cases/TEST_CASES.md      executed, exploratory and blocked cases (ID/steps/expected/actual/status)
tests/maestro/                config.yaml, flows/ (13), subflows/ (5), scripts/
tests/fixtures/               dummy PDF/PNG used by the upload steps (labelled test files)
tests/run_all.sh              one-command runner (adb/app checks + JUnit + artifacts)
bugreports/BUG-00*.md         3 confirmed defects with evidence
evidence/runs/<run>/          Maestro screenshots, hierarchies, logs, JUnit report.xml per run
evidence/screenshots/         curated screenshots
docs/EXECUTION_SUMMARY.md     actual results of every recorded run
docs/ENVIRONMENT.md           exact versions, APK hash
```
Scope note: the PDF mixes the QA brief with Flutter-track (posture tracker) requirements and an appendix marked
"QA track can ignore this". The supplied app is an OTP-login app, so scope = QA brief. Details in `TEST_PLAN.md` §1.

## Prerequisites (macOS, Apple silicon; Linux works the same with a matching system image)
```bash
brew install openjdk@17 mobile-dev-inc/tap/maestro
brew install --cask android-commandlinetools
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
export ANDROID_SDK_ROOT=/opt/homebrew/share/android-commandlinetools
export PATH=$JAVA_HOME/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH
yes | sdkmanager --licenses
sdkmanager "platform-tools" "emulator" "platforms;android-34" "system-images;android-34;google_apis;arm64-v8a"
```
(`x86_64` host: use the `x86_64` system image.) A physical Android 8+ device with USB debugging also works.

## Create and start the emulator
```bash
echo no | avdmanager create avd -n qa_pixel -k "system-images;android-34;google_apis;arm64-v8a" --force
# realistic phone profile (the default profile is a tiny 320x640 screen)
CFG=~/.android/avd/qa_pixel.avd/config.ini
sed -i.bak -e 's/^hw.lcd.density=.*/hw.lcd.density=420/' -e 's/^hw.lcd.height=.*/hw.lcd.height=2400/' \
           -e 's/^hw.lcd.width=.*/hw.lcd.width=1080/' -e 's/^hw.ramSize=.*/hw.ramSize=4096/' "$CFG"
emulator -avd qa_pixel -no-snapshot -no-audio -gpu host &
adb wait-for-device
```
(An `avdmanager` message about `devices.xml` is harmless.)

## Install the app
```bash
adb install -r /path/to/app-debug.apk        # do NOT pass -g: the flows manage permissions
```

## Test data
* The app accepts a shared **test OTP** for any phone number (supplied by the hiring team, not committed here).
  Pass it as an environment variable; never hard-code it: `export MAESTRO_TEST_OTP=<test otp>`.
* Each run signs up with a random number `90000xxxxx` and e-mail `qa.<number>@example.com`, so runs never collide.
* TC-LOG-01 logs in with an account that already finished onboarding. By default it uses `9000000000`
  (created during test development); override with `MAESTRO_EXISTING_PHONE=<number>` or create one by running flow 09 first.
* Upload steps use `tests/fixtures/dummy_test_document.pdf`; `run_all.sh` pushes it to the device's Downloads folder.

## Run the tests
```bash
export MAESTRO_TEST_OTP=<test otp>
tests/run_all.sh run1                         # 11 flows + TC-LOG-01, ~13 min, output in evidence/runs/run1/
INCLUDE_KNOWN_BUGS=1 tests/run_all.sh run2    # also runs the BUG-001 repro (it fails by design)
unset MAESTRO_TEST_OTP; tests/run_all.sh pre  # only the 8 pre-OTP flows (no test data needed), ~5 min
# a single flow (push the fixture first if the flow uploads documents):
cd tests/maestro && maestro test flows/01_welcome_screen.yaml
cd tests/maestro && maestro test flows/09_e2e_signup_to_verification_pending.yaml -e MAESTRO_TEST_OTP=$MAESTRO_TEST_OTP
```
Expected: `11/11 Flows Passed`, then `TC-LOG-01 … Passed`. Flows wipe app data first, so order does not matter.
TC-NET-01 toggles airplane mode and restores it; `launch_fresh` also disables it as a safety net.

### Reading the results
* `evidence/runs/<run>/report.xml` — JUnit summary. Per flow: named evidence screenshots and logs.
* On failure Maestro stores the screenshot + hierarchy of the failing step — start there.
* Excluded by tag (`tests/maestro/config.yaml`): `known-bug` (BUG-001 repro) and `requires-existing-account` (run separately).

## Design decisions
* **Flutter app → accessibility labels.** Text lives in accessibility labels, so selectors are label regexes (e.g. `Phone Number.*`).
  The text field's hint is multi-line, hence the `.*`.
* **Maestro grants all permissions on launch by default**, which hides the notification dialog. `launch_fresh` passes
  `permissions: all: unset`; TC-PRM-01 asserts the dialog strictly, other flows treat it as optional (Android sometimes
  suppresses it after repeated denials in one device session).
* **No fixed sleeps**, except `scripts/wait_for_toast.js`, used only to time an evidence screenshot because the toast cannot be awaited via selectors (BUG-001).
* **No OTP to real people.** Negative tests press *Send OTP* only with impossible numbers (`0…`/`1…`) or while offline; sign-up tests use the test OTP with synthetic `90000xxxxx` numbers on the hiring team's test backend.
* **Document pickers:** the Android picker's *Recent*/search are empty for pushed files, so the subflow opens *Downloads* explicitly, after the drawer animation finishes; the PNG is disabled in PDF-only slots, so the PDF is picked by exact name.
* **Animation-safe taps:** Flutter swallows taps during selection/route animations, so key transitions use `waitForAnimationToEnd` and a retry guard instead of fixed sleeps.

## Known limitations
* **Verification outcome not testable:** identity/profile review is human and asynchronous ("up to 24 hours"); only the pending state and its persistence are verified.
* **Not executed** (see `TEST_CASES.md` §C): OTP expiry/resend/rate-limit, unregistered-number login, duplicate e-mail/phone, DOB and text boundaries, large/corrupt uploads, TalkBack, rotation/dark mode/low memory.
* Emulator only (Android 14 arm64, one device profile); debug build; no physical or low-end device.
* Tests create real accounts on the test backend (one per run); they cannot be deleted from the app.
* Two full consecutive runs is a small reliability sample. Earlier, before the launch step was hardened, 1 of 24 flow runs failed because the app launched on a stale Login screen (`evidence/logs/`).
* The screen-recording `evidence/demo/` is kept out of git because it shows the test OTP being typed; see `docs/DEMO_RECORDING.md`.
