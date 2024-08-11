
/*import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  //final apiKey = Platform.environment['GOOGLE_API_KEY'];
  final apiKey = 'AIzaSyCwHEytPNK05Bv0wFALHlG2eilEUCvyM7w';
  if (apiKey == null) {
    stderr.writeln(r'No $GOOGLE_API_KEY environment variable');
    exit(1);
  }
  final model = GenerativeModel(
      model: 'models/gemini-1.5-pro',
      apiKey: apiKey,
      safetySettings: [
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high)
      ],
      generationConfig: GenerationConfig(maxOutputTokens: 200));
  final prompt = 'Write a story about a magic backpack.';
  print('Prompt: $prompt');
  final content = [Content.text(prompt)];
  final tokenCount = await model.countTokens(content);
  print('Token count: ${tokenCount.totalTokens}');

  final response = await model.generateContent(content);
  print('Response:');
  print(response.text);
} */
// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:io';
//import 'package:path/path.dart' as path;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:typed_data';
import 'package:path/path.dart' as path;

Future<Uint8List> readResource(String name) {
  return File(path.join('.', name)).readAsBytes();
}
void main() async {
  //final apiKey = Platform.environment['GOOGLE_API_KEY'];
  //if (apiKey == null) {
  //  stderr.writeln(r'No $GOOGLE_API_KEY environment variable');
  //  exit(1);
  //}
  final model = GenerativeModel(
    model: 'gemini-1.5-pro',
    apiKey: 'AIzaSyCwHEytPNK05Bv0wFALHlG2eilEUCvyM7w',
  );
  final prompt = 'Can you read and generate the content from these documents?';
  print('Prompt: $prompt');

  final (FrenchBytes,ProjectBytes) = await (
    readResource('French_Translations.docx'),
    readResource('French_Translations.docx'),
  ).wait;
  final content = [
    Content.multi([
      TextPart(prompt),
      // The only accepted mime types are image/*.
      DataPart('docx', FrenchBytes),
      DataPart('docx', ProjectBytes),
    ])
  ];

  final response = await model.generateContent(content);
  print('Response:');
  print(response.text);
}
/*class GeminiClient {
  GeminiClient({
    required this.model,
  });

  final GenerativeModel model;

  Future generateContentFromText({
    required String prompt,
  }) async {
    final response = await model.generateContent([Content.text(prompt)]);
    print(response.text);
    return response.text;
  }


}
void main() async {
  String userPrompt = "Enter your prompt here"; // Replace with user input mechanism

  final response = await generateContentFromText(prompt: userPrompt);
  if (response.isNotEmpty) {
    print(response.text); // Or use the response for UI updates
  } else {
    // Handle potential errors or empty responses
  }
}

Future<String> generateContentFromText({
  required String prompt,
}) async {
  final response = await model.generateContent([Content.text(prompt)]);
  return response.text;
} */