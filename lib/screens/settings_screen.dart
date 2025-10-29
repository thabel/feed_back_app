import 'package:flutter/material.dart';
import '../services/feedback_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FeedbackService _feedbackService = FeedbackService();
  final TextEditingController _passwordController = TextEditingController();
  bool _isAuthenticated = false;
  List<Map<String, String>> _questionnaires = [];
  String? _selectedQuestionnaireId;
  bool _isLoading = false;

  // Admin password (in production, this should be from backend)
  static const String ADMIN_PASSWORD = '1234';

  @override
  void initState() {
    super.initState();
    _loadQuestionnaires();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestionnaires() async {
    setState(() => _isLoading = true);
    try {
      final questionnaires = await _feedbackService.getQuestionnairesList();
      setState(() {
        _questionnaires = questionnaires;
        _selectedQuestionnaireId = _feedbackService.currentQuestionnaireId;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _validatePassword() {
    if (_passwordController.text == ADMIN_PASSWORD) {
      setState(() => _isAuthenticated = true);
      _passwordController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mot de passe incorrect'),
          backgroundColor: Colors.red,
        ),
      );
      _passwordController.clear();
    }
  }

  Future<void> _changeQuestionnaire() async {
    if (_selectedQuestionnaireId == null) return;

    setState(() => _isLoading = true);

    try {
      final success = await _feedbackService.setActiveQuestionnaire(
        _selectedQuestionnaireId!,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Questionnaire changé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isLoading = false);
        Navigator.of(context).pop(true); // Return true to indicate change
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: _isAuthenticated ? _buildAdminPanel() : _buildAuthenticationPanel(),
    );
  }

  Widget _buildAuthenticationPanel() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lock icon
              Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.blue[400],
              ),
              const SizedBox(height: 32),
              // Title
              const Text(
                'Accès Administrateur',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                'Entrez le mot de passe pour accéder aux paramètres',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),
              // Password input
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                onSubmitted: (_) => _validatePassword(),
              ),
              const SizedBox(height: 24),
              // Validate button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _validatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Valider',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminPanel() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            const Text(
              'Bienvenue Administrateur',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            // Section title
            const Text(
              'Changer le Questionnaire',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            // Loading state
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_questionnaires.isEmpty)
              Center(
                child: Text(
                  'Aucun questionnaire disponible',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            else
              Column(
                children: [
                  // Questionnaire list
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: _questionnaires
                          .asMap()
                          .entries
                          .map((entry) {
                            final index = entry.key;
                            final questionnaire = entry.value;
                            final isSelected =
                                questionnaire['id'] == _selectedQuestionnaireId;
                            final isLast = index == _questionnaires.length - 1;

                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedQuestionnaireId =
                                          questionnaire['id'];
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    color: isSelected
                                        ? Colors.blue[50]
                                        : Colors.white,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.blue
                                                  : Colors.grey,
                                              width: 2,
                                            ),
                                          ),
                                          child: isSelected
                                              ? Center(
                                                  child: Container(
                                                    width: 12,
                                                    height: 12,
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape:
                                                          BoxShape.circle,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                questionnaire['name'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'ID: ${questionnaire['id']}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (!isLast)
                                  Divider(
                                    height: 1,
                                    color: Colors.grey[300],
                                  ),
                              ],
                            );
                          })
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _changeQuestionnaire,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                          : const Text(
                              'Appliquer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 32),
            // Logout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _isAuthenticated = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Déconnexion',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
