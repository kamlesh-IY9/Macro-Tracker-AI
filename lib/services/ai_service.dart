import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String _geminiKeyKey = 'gemini_api_key';
  static const String _chatgptKeyKey = 'chatgpt_api_key';
  static const String _useGeminiKey = 'use_gemini';

  // Get API keys
  Future<String?> getGeminiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_geminiKeyKey);
  }

  Future<String?> getChatGPTKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chatgptKeyKey);
  }

  Future<bool> shouldUseGemini() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_useGeminiKey) ?? true; // Default to Gemini
  }

  Future<void> setUseGemini(bool useGemini) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useGeminiKey, useGemini);
  }

  Future<void> saveGeminiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiKeyKey, key);
  }

  Future<void> saveChatGPTKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chatgptKeyKey, key);
  }

  // Analyze food with AI (text or image)
  Future<Map<String, dynamic>> analyzeFood(String? textInput, List<int>? imageBytes) async {
    final useGemini = await shouldUseGemini();
    
    try {
      if (useGemini) {
        return await _analyzeWithGemini(textInput, imageBytes != null ? Uint8List.fromList(imageBytes) : null);
      } else {
        return await _analyzeWithChatGPT(textInput, imageBytes != null ? Uint8List.fromList(imageBytes) : null);
      }
    } catch (e) {
      // If primary fails, try fallback
      if (useGemini) {
        try {
          return await _analyzeWithChatGPT(textInput, imageBytes != null ? Uint8List.fromList(imageBytes) : null);
        } catch (_) {
          rethrow;
        }
      } else {
        try {
          return await _analyzeWithGemini(textInput, imageBytes != null ? Uint8List.fromList(imageBytes) : null);
        } catch (_) {
          rethrow;
        }
      }
    }
  }

  Future<Map<String, dynamic>> _analyzeWithGemini(String? textInput, Uint8List? imageBytes) async {
    final apiKey = await getGeminiKey();
    if (apiKey == null) throw Exception('Gemini API Key not set');

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    final prompt = '''
Analyze this food and provide nutritional information in JSON format.
${textInput != null ? 'Food description: $textInput' : 'Analyze the food in the image.'}

Return ONLY valid JSON in this exact format:
{
  "name": "Food name",
  "calories": 0,
  "protein": 0,
  "carbs": 0,
  "fat": 0,
  "servingSize": "e.g. 100g, 1 cup"
}
''';

    try {
      final Content content;
      if (imageBytes != null) {
        content = Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ]);
      } else {
        content = Content.text(prompt);
      }

      final response = await model.generateContent([content]);
      final text = response.text ?? '';
      
      // Extract JSON from response
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(0)!);
      }
      
      throw Exception('Could not parse AI response');
    } catch (e) {
      throw Exception('Gemini analysis failed: $e');
    }
  }

  Future<Map<String, dynamic>> _analyzeWithChatGPT(String? textInput, List<int>? imageBytes) async {
    final apiKey = await getChatGPTKey();
    if (apiKey == null) throw Exception('ChatGPT API Key not set');

    final prompt = '''
Analyze this food and provide nutritional information in JSON format.
${textInput != null ? 'Food description: $textInput' : 'Analyze the food in the image.'}

Return ONLY valid JSON in this exact format:
{
  "name": "Food name",
  "calories": 0,
  "protein": 0,
  "carbs": 0,
  "fat": 0,
  "servingSize": "e.g. 100g, 1 cup"
}
''';

    try {
      final messages = <Map<String, dynamic>>[];
      
      if (imageBytes != null) {
        // For GPT-4 Vision
        final base64Image = base64Encode(imageBytes);
        messages.add({
          'role': 'user',
          'content': [
            {'type': 'text', 'text': prompt},
            {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}
            }
          ]
        });
      } else {
        messages.add({'role': 'user', 'content': prompt});
      }

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': imageBytes != null ? 'gpt-4-vision-preview' : 'gpt-4-turbo-preview',
          'messages': messages,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices'][0]['message']['content'];
        
        // Extract JSON from response
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
        if (jsonMatch != null) {
          return jsonDecode(jsonMatch.group(0)!);
        }
      }
      
      throw Exception('ChatGPT API error: ${response.statusCode}');
    } catch (e) {
      throw Exception('ChatGPT analysis failed: $e');
    }
  }

  // Chat function for AI Coach
  Future<String> chat(String prompt) async {
    final useGemini = await shouldUseGemini();
    
    try {
      if (useGemini) {
        return await _chatWithGemini(prompt);
      } else {
        return await _chatWithChatGPT(prompt);
      }
    } catch (e) {
      // Fallback
      if (useGemini) {
        try {
          return await _chatWithChatGPT(prompt);
        } catch (_) {
          return 'Error: $e';
        }
      } else {
        try {
          return await _chatWithGemini(prompt);
        } catch (_) {
          return 'Error: $e';
        }
      }
    }
  }

  Future<String> _chatWithGemini(String prompt) async {
    final apiKey = await getGeminiKey();
    if (apiKey == null) return "Please set your Gemini API Key in Settings.";

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "I'm not sure how to respond to that.";
    } catch (e) {
      return "Error connecting to Gemini: $e";
    }
  }

  Future<String> _chatWithChatGPT(String prompt) async {
    final apiKey = await getChatGPTKey();
    if (apiKey == null) return "Please set your ChatGPT API Key in Settings.";

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4-turbo-preview',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      }
      
      return "ChatGPT API error: ${response.statusCode}";
    } catch (e) {
      return "Error connecting to ChatGPT: $e";
    }
  }
}
