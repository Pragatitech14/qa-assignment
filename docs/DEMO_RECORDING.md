# Demo recording

`evidence/demo/` holds two screen recordings of **TC-E2E-01** (full onboarding, ~5 min), taken with Android's
`screenrecord` while the Maestro flow drove the real app on the emulator:

* `demo_part1_stages1-4.mp4` — wiped install → phone OTP → personal details → email OTP → role → document uploads → experience
* `demo_part2_stages5-7_and_end_state.mp4` — specialisation → institute → practice details (required-field errors, fill, availability)
  → *Verification in progress* → relaunch

(`screenrecord` stops after 3 minutes, hence two parts.) The files are **not committed to git**: they show the test OTP being
typed. Share them through the Google Drive folder.

Re-create (emulator running, app installed):
```bash
export MAESTRO_TEST_OTP=<test otp>
adb push tests/fixtures/dummy_test_document.pdf /sdcard/Download/
adb shell screenrecord --time-limit 175 /sdcard/part1.mp4 &      # start a second one after it ends
cd tests/maestro && maestro test flows/09_e2e_signup_to_verification_pending.yaml -e MAESTRO_TEST_OTP=$MAESTRO_TEST_OTP
adb pull /sdcard/part1.mp4
```
`maestro record --local` also works but rendered a >300 MB file after 30 minutes here, so it was not used.

Talking points for a narrated take: scope decision, Flutter selectors via accessibility labels, launch/permission handling,
the file-picker workaround, BUG-001 (toast not in the accessibility tree), and what could not be tested.
