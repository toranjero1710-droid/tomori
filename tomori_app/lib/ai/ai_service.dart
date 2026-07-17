import 'models/tomori_letter_input.dart';

abstract class AiService {
  Future<String> generateTomoriLetter(TomoriLetterInput input);
}

class AiConfigurationException implements Exception {
  const AiConfigurationException(this.message, {this.isNetworkFailure = false});

  final String message;
  final bool isNetworkFailure;

  @override
  String toString() => message;
}
