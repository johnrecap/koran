abstract class AiProvider {
  Future<String> generate({
    required String prompt,
    required String systemPrompt,
    int? maxTokens,
    double? temperature,
  });

  Future<bool> isAvailable();

  String get providerName;
}
