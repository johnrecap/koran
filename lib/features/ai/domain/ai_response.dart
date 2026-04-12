class AiResponse {
  AiResponse({
    required this.text,
    this.inputTokens,
    this.outputTokens,
    required this.latencyMs,
    required this.providerName,
    required this.timestamp,
  });

  factory AiResponse.fromRaw(
    String text,
    String provider,
    int latencyMs,
  ) {
    return AiResponse(
      text: text,
      latencyMs: latencyMs,
      providerName: provider,
      timestamp: DateTime.now(),
    );
  }

  final String text;
  final int? inputTokens;
  final int? outputTokens;
  final int latencyMs;
  final String providerName;
  final DateTime timestamp;

  bool get isEmpty => text.trim().isEmpty;
}
