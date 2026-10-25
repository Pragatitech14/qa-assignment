// The app's validation toast is not in the accessibility tree (see BUG-001), so
// it cannot be awaited with a selector. It appears ~2.5 s after tapping Send OTP
// and stays ~2 s. This fixed delay is used ONLY to time an evidence screenshot.
var start = Date.now();
while (Date.now() - start < 3500) {}
