import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());

class GeminiService {
  static const String _apiKeyKey = 'gemini_api_key';

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  Future<Map<String, dynamic>> analyzeFood(String input, {Uint8List? imageBytes}) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API Key not found. Please set it in Settings.');
    }

    final modelName = imageBytes != null ? 'gemini-1.5-flash' : 'gemini-1.5-flash';
    final model = GenerativeModel(model: modelName, apiKey: apiKey);

    final prompt = '''
    Analyze the following food input and return a JSON object with the nutritional information.
    Input: "$input"
    
    Return ONLY raw JSON (no markdown formatting) with the following keys:
    - name: Short descriptive name of the food
    - calories: Total calories (number)
    - protein: Protein in grams (number)
    - carbs: Carbs in grams (number)
    - fat: Fat in grams (number)
    
    If the input is not food or cannot be analyzed, return: {"error": "Invalid input"}
    ''';

    final content = [
      Content.multi([
        TextPart(prompt),
        if (imageBytes != null) DataPart('image/jpeg', imageBytes),
      ])
    ];

    final response = await model.generateContent(content);
    
    final text = response.text;
    if (text == null) throw Exception('No response from AI');

    // Clean up markdown if present (```json ... ```)
    final cleanText = text.replaceAll(RegExp(r'```json|```'), '').trim();

    try {
      return jsonDecode(cleanText) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to parse AI response: $text');
    }
  }

  Future<String> chat(String prompt) async {
    final apiKey = await getApiKey();
    if (apiKey == null) return "Please set your API Key in Settings.";

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "I'm not sure how to respond to that.";
    } catch (e) {
      return "Error connecting to AI: $e";
    }
  }
}
