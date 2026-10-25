#!/usr/bin/env bash
# Runs the Maestro suite against the device/emulator that adb sees.
# Usage: MAESTRO_TEST_OTP=<test otp> tests/run_all.sh [run-name]
#   - Without MAESTRO_TEST_OTP only the 8 pre-OTP flows run (flows tagged requires-otp are skipped).
#   - INCLUDE_KNOWN_BUGS=1 also runs the BUG-001 repro (fails by design).
#   - MAESTRO_EXISTING_PHONE: number that already finished onboarding, for TC-LOG-01
#     (default 9000000000, created during test development).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RUN="${1:-$(date +%Y%m%d-%H%M%S)}"
OUT="$ROOT/evidence/runs/$RUN"
APP_ID="com.manastik.dadtmedico"

command -v maestro >/dev/null || { echo "maestro not found - see README prerequisites"; exit 2; }
command -v adb >/dev/null     || { echo "adb not found - see README prerequisites"; exit 2; }
adb get-state >/dev/null 2>&1 || { echo "no device/emulator connected (adb devices)"; exit 2; }
adb shell pm list packages | grep -q "package:$APP_ID" \
  || { echo "$APP_ID not installed. Run: adb install -r path/to/app-debug.apk"; exit 2; }

# Dummy documents for the upload steps (clearly labelled test files, see tests/fixtures)
adb push "$ROOT/tests/fixtures/dummy_test_document.pdf" /sdcard/Download/ >/dev/null
adb push "$ROOT/tests/fixtures/dummy_test_document.png" /sdcard/Download/ >/dev/null
adb shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE \
  -d file:///sdcard/Download/dummy_test_document.pdf >/dev/null

mkdir -p "$OUT"
cd "$ROOT/tests/maestro"
EXTRA=()
if [[ -n "${MAESTRO_TEST_OTP:-}" ]]; then
  EXTRA+=(-e "MAESTRO_TEST_OTP=$MAESTRO_TEST_OTP")
else
  echo "MAESTRO_TEST_OTP not set -> skipping flows that need the OTP"
  EXTRA+=(--exclude-tags requires-otp,known-bug,requires-existing-account)
fi
maestro test . --config config.yaml "${EXTRA[@]}" \
  --test-output-dir "$OUT" --format junit --output "$OUT/report.xml"

if [[ -n "${MAESTRO_TEST_OTP:-}" ]]; then
  echo "--- TC-LOG-01 (existing account) ---"
  mkdir -p "$OUT/existing-account"
  maestro test flows/13_login_existing_account.yaml \
    -e "MAESTRO_TEST_OTP=$MAESTRO_TEST_OTP" \
    -e "MAESTRO_EXISTING_PHONE=${MAESTRO_EXISTING_PHONE:-9000000000}" \
    --test-output-dir "$OUT/existing-account" --format junit --output "$OUT/existing-account/report.xml"
fi

if [[ "${INCLUDE_KNOWN_BUGS:-0}" == "1" ]]; then
  echo "--- known-bug flows (expected to FAIL) ---"
  mkdir -p "$OUT/known-bugs"
  maestro test flows/10_bug001_validation_toast_accessible.yaml \
    --test-output-dir "$OUT/known-bugs" || true
fi
