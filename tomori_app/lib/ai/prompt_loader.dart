import 'package:flutter/services.dart';

class PromptLoader {
  const PromptLoader();

  Future<String> load(String name) {
    return rootBundle.loadString('lib/ai/prompts/$name.md');
  }
}
