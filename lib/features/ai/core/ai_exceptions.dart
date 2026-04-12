class AiServiceException implements Exception {
  AiServiceException({
    required this.message,
    this.provider,
    this.originalError,
  });

  final String message;
  final String? provider;
  final Object? originalError;

  @override
  String toString() {
    final providerLabel = provider == null ? '' : ', provider: $provider';
    final errorLabel =
        originalError == null ? '' : ', originalError: $originalError';
    return '$runtimeType(message: $message$providerLabel$errorLabel)';
  }
}

class AiTimeoutException extends AiServiceException {
  AiTimeoutException({
    required super.message,
    super.provider,
    super.originalError,
  });
}

class AiQuotaExceededException extends AiServiceException {
  AiQuotaExceededException({
    required super.message,
    super.provider,
    super.originalError,
  });
}

class AiOfflineException extends AiServiceException {
  AiOfflineException({
    required super.message,
    super.provider,
    super.originalError,
  });
}

class AiProviderException extends AiServiceException {
  AiProviderException({
    required super.message,
    super.provider,
    super.originalError,
  });
}

class AiSafetyException extends AiServiceException {
  AiSafetyException({
    required super.message,
    super.provider,
    super.originalError,
  });
}
