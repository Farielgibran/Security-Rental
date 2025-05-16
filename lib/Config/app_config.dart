class AppConfig {
  // API URL berdasarkan environment
  static const String apiUrl =
      'https://testcardeki.my.id/v1/api'; // untuk emulator Android
  // static const String apiUrl = 'http://localhost:5000'; // untuk iOS simulator
  // static const String apiUrl = 'https://api.example.com'; // untuk production

  // Konfigurasi fitur verifikasi wajah
  static const bool faceVerificationRequired = true;
  static const double minFaceConfidence =
      0.7; // minimum confidence untuk verifikasi wajah

  // Konfigurasi aplikasi
  static const String appName = 'M-Security check Mobil App';
  static const String appVersion = '1.0.0';

  // Lokasi penyimpanan gambar
  static const String storagePath = '/storage/rental_app/';

  // Konfigurasi waktu
  static const int sessionTimeoutMinutes = 30;
  static const int maxRentalDays = 30;
  static const int minRentalDays = 1;
  static const int maxAdvanceBookingDays = 90;

  // Konfigurasi pemberitahuan
  static const bool enablePushNotifications = true;

  // Demo mode (untuk development tanpa backend)
  static const bool demoMode = true; // set false untuk produksi
}
