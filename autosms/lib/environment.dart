/// Singleton class that helps easy access to the environment variables.
final class Environment {
  Environment._();

  static const msalAadClientId = String.fromEnvironment('MSAL_AAD_CLIENT_ID');
  static const msalAadAndroidRedirectUri = String.fromEnvironment('MSAL_AAD_ANDROID_REDIRECT_URI');
  static const aadIosAuthority = String.fromEnvironment('MSAL_AAD_APPLE_AUTHORITY');
}