class AppConfig {
  // API Configuration
  static const String _iosSimulatorUrl = 'http://localhost:3000';
  static const String _androidEmulatorUrl = 'http://10.0.2.2:3000';
  static const String _localDeviceUrl = 'http://192.168.1.100:3000';
  static const String _productionUrl = 'https://your-production-url.com';

  // Set this to _androidEmulatorUrl for Android emulator, _iosSimulatorUrl for iOS simulator, or _localDeviceUrl for real device
  static const String apiBaseUrl = _androidEmulatorUrl;

  // Platform Detection
  static bool get isAndroidEmulator =>
      bool.fromEnvironment('ANDROID_EMULATOR', defaultValue: true);

  // App Configuration
  static const String appName = 'MyDoApp';
  static const String appVersion = '1.0.0';

  // Timeout Configuration
  static const int loginTimeoutSeconds = 30;
  static const int logoutTimeoutSeconds = 10;
  static const int generalTimeoutSeconds = 15;

  // Validation Configuration
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;

  // Storage Keys
  static const String userDataKey = 'user_data';
  static const String authTokenKey = 'auth_token';

  // Development Configuration
  static const bool isDevelopmentMode = true;

  // Logging Configuration
  static const bool enableDebugLogging = true;

  // Feature Flags
  static const bool enableTokenRefresh = true;

  static const bool enableOfflineMode = false;

  // Environment Detection
  static bool get isProduction => !isDevelopmentMode;
  static bool get isDebug => enableDebugLogging;
}
