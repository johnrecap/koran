class AiProviderConfig {
  const AiProviderConfig({
    required this.apiKey,
    required this.model,
    this.baseUrl,
    this.timeoutSeconds = 15,
    this.maxOutputTokens = 1024,
    this.temperature = 0.3,
  });

  static const String _geminiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  static const String _groqKey =
      String.fromEnvironment('GROQ_API_KEY', defaultValue: '');

  factory AiProviderConfig.gemini([String? apiKey]) {
    return AiProviderConfig(
      apiKey: apiKey ?? _geminiKey,
      model: 'gemini-2.5-flash',
      timeoutSeconds: 15,
      maxOutputTokens: 1024,
      temperature: 0.3,
    );
  }

  factory AiProviderConfig.groq([String? apiKey]) {
    return AiProviderConfig(
      apiKey: apiKey ?? _groqKey,
      model: 'llama-3.3-70b-versatile',
      baseUrl: 'https://api.groq.com/openai/v1',
      timeoutSeconds: 15,
      maxOutputTokens: 1024,
      temperature: 0.3,
    );
  }

  final String apiKey;
  final String model;
  final String? baseUrl;
  final int timeoutSeconds;
  final int maxOutputTokens;
  final double temperature;
}
