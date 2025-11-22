import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/ai_service.dart';
import '../../providers/ai_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _geminiKeyController = TextEditingController();
  final _chatgptKeyController = TextEditingController();
  bool _useGemini = true;

  @override
  void initState() {
    super.initState();
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    final aiService = ref.read(aiServiceProvider);
    final geminiKey = await aiService.getGeminiKey();
    final chatgptKey = await aiService.getChatGPTKey();
    final useGemini = await aiService.shouldUseGemini();
    
    setState(() {
      _geminiKeyController.text = geminiKey ?? '';
      _chatgptKeyController.text = chatgptKey ?? '';
      _useGemini = useGemini;
    });
  }

  Future<void> _saveKeys() async {
    final aiService = ref.read(aiServiceProvider);
    
    if (_geminiKeyController.text.trim().isNotEmpty) {
      await aiService.saveGeminiKey(_geminiKeyController.text.trim());
    }
    
    if (_chatgptKeyController.text.trim().isNotEmpty) {
      await aiService.saveChatGPTKey(_chatgptKeyController.text.trim());
    }
    
    await aiService.setUseGemini(_useGemini);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API Keys Saved Successfully!'),
          backgroundColor: Color(0xFF00D9C0),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Configuration',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configure your AI providers for food logging',
              style: TextStyle(color: Color(0xFF888888), fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Primary AI Selection
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Primary AI Provider',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Gemini', style: TextStyle(color: Colors.white)),
                          value: true,
                          groupValue: _useGemini,
                          onChanged: (val) => setState(() => _useGemini = val!),
                          activeColor: const Color(0xFF00D9C0),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('ChatGPT', style: TextStyle(color: Colors.white)),
                          value: false,
                          groupValue: _useGemini,
                          onChanged: (val) => setState(() => _useGemini = val!),
                          activeColor: const Color(0xFF00D9C0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Gemini API Key
            const Text(
              'Gemini API Key',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Get your free API key from makersuite.google.com',
              style: TextStyle(color: Color(0xFF888888), fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _geminiKeyController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter Gemini API Key',
                hintStyle: const TextStyle(color: Color(0xFF888888)),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.key, color: Color(0xFF00D9C0)),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),

            // ChatGPT API Key
            const Text(
              'ChatGPT API Key (Fallback)',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Get your API key from platform.openai.com',
              style: TextStyle(color: Color(0xFF888888), fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _chatgptKeyController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter ChatGPT API Key',
                hintStyle: const TextStyle(color: Color(0xFF888888)),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.key, color: Color(0xFF00D9C0)),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveKeys,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D9C0),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _geminiKeyController.dispose();
    _chatgptKeyController.dispose();
    super.dispose();
  }
}
