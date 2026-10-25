// Unique test number per run so sign-up never collides with an earlier test account.
// 90000 + 5 random digits. The backend accepts the shared test OTP for any number.
output.phone = '90000' + String(Math.floor(Math.random() * 100000)).padStart(5, '0');
output.email = "qa." + output.phone + "@example.com";
