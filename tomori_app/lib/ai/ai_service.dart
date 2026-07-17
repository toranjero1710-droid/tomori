import 'models/tomori_letter_input.dart';

abstract class AiService {
  Future<String> generateTomoriLetter(TomoriLetterInput input);
}

class AiConfigurationException implements Exception {
  const AiConfigurationException(this.message);

  final String message;

  @override
  String toString() => message;
}
