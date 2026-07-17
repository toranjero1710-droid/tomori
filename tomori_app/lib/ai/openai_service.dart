import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'ai_service.dart';
import 'models/tomori_letter_input.dart';
import 'prompt_loader.dart';

class OpenAiService implements AiService {
  OpenAiService({
    http.Client? client,
    this.promptLoader = const PromptLoader(),
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final PromptLoader promptLoader;

  static const _responsesUrl = 'https://api.openai.com/v1/responses';

  @override
  Future<String> generateTomoriLetter(TomoriLetterInput input) async {
    final apiKey = dotenv.env['OPENAI_API_KEY']?.trim() ?? '';
    final model = dotenv.env['OPENAI_MODEL']?.trim() ?? '';
    if (apiKey.isEmpty) {
      throw const AiConfigurationException('OPENAI_API_KEY is not configured.');
    }
    if (model.isEmpty) {
      throw const AiConfigurationException('OPENAI_MODEL is not configured.');
    }

    final prompt = await promptLoader.load('tomori_letter');
    final response = await _client.post(
      Uri.parse(_responsesUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'instructions': prompt,
        'input': input.toPromptInput(),
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AiConfigurationException('OpenAI API request failed: ${response.statusCode}');
    }
    final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final outputText = json['output_text'];
    if (outputText is String && outputText.trim().isNotEmpty) {
      return outputText.trim();
    }
    final fallback = _extractText(json);
    if (fallback.trim().isEmpty) {
      throw const AiConfigurationException('OpenAI API returned no text.');
    }
    return fallback.trim();
  }

  String _extractText(Map<String, dynamic> json) {
    final output = json['output'];
    if (output is! List) return '';
    final buffer = StringBuffer();
    for (final item in output) {
      if (item is! Map<String, dynamic>) continue;
      final content = item['content'];
      if (content is! List) continue;
      for (final part in content) {
        if (part is Map<String, dynamic>) {
          final text = part['text'];
          if (text is String) buffer.writeln(text);
        }
      }
    }
    return buffer.toString();
  }
}
