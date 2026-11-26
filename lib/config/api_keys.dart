/// API keys are provided at build time and must not be committed.
class ApiKeys {
  static const String giphyApiKey = String.fromEnvironment('GIPHY_API_KEY');
}
