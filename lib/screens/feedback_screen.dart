import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/question.dart';
import '../services/feedback_service.dart';
import '../widgets/question_widgets.dart';
import '../utils/validators.dart';
import 'settings_screen.dart';
import 'dart:async';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final FeedbackService _feedbackService = FeedbackService();
  Questionnaire? _currentQuestionnaire;
  int _currentQuestionIndex = 0;
  Map<String, dynamic> _answers = {};
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _showEndMessage = false;
  Timer? _resetTimer;

  @override
  void initState() {
    super.initState();
    _loadQuestionnaire();
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestionnaire() async {
    setState(() => _isLoading = true);
    try {
      final questionnaire = await _feedbackService.getCurrentQuestionnaire();
      setState(() {
        _currentQuestionnaire = questionnaire;
        _isLoading = false;
        _currentQuestionIndex = 0;
        _answers = {};
        _showEndMessage = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _refreshQuestionnaire() {
    _resetTimer?.cancel();
    _loadQuestionnaire();
  }

  void _nextQuestion() {
    if (_currentQuestionnaire == null) return;

    final currentQuestion = _currentQuestionnaire!.questions[_currentQuestionIndex];
    final answer = _answers[currentQuestion.id];

    // Validation
    String? validationError = _validateQuestion(currentQuestion, answer);

    if (validationError != null) {
      // Show error as modal dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Validation'),
          content: Text(validationError),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (_currentQuestionIndex < _currentQuestionnaire!.questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      _submitFeedback();
    }
  }

  String? _validateQuestion(Question question, dynamic answer) {
    // Check if mandatory field is empty
    if (question.isMandatory) {
      if (answer == null || answer == '' || answer == 0) {
        return 'Cette question est obligatoire';
      }

      // Validate email
      if (question.type == QuestionType.email && answer is String) {
        if (!Validators.isValidEmail(answer)) {
          return 'Veuillez entrer un email valide';
        }
      }

      // Validate phone
      if (question.type == QuestionType.phone && answer is String) {
        if (!Validators.isValidPhone(answer)) {
          return 'Veuillez entrer un numéro de téléphone valide (minimum 8 chiffres)';
        }
      }
    }

    return null;
  }

  Future<void> _submitFeedback() async {
    if (_currentQuestionnaire == null) return;

    setState(() => _isSubmitting = true);

    try {
      final response = FeedbackResponse(
        id: const Uuid().v4(),
        questionnaireId: _currentQuestionnaire!.id,
        answers: _answers.entries
            .map((e) => Answer(
                  questionId: e.key,
                  value: e.value,
                  timestamp: DateTime.now(),
                ))
            .toList(),
        submittedAt: DateTime.now(),
      );

      final success = await _feedbackService.submitFeedback(response);

      if (success && mounted) {
        setState(() {
          _isSubmitting = false;
          _showEndMessage = true;
        });

        // Reset after 20 seconds
        _resetTimer?.cancel();
        _resetTimer = Timer(const Duration(seconds: 20), () {
          if (mounted) {
            _loadQuestionnaire();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la soumission: $e')),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Feedback Center',
          style: TextStyle(fontSize: isTablet ? 24 : 20),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          // Refresh button
          IconButton(
            icon: Icon(
              Icons.refresh,
              size: isTablet ? 28 : 24,
            ),
            onPressed: _refreshQuestionnaire,
            splashRadius: isTablet ? 28 : 24,
          ),
          // Settings button
          IconButton(
            icon: Icon(
              Icons.settings,
              size: isTablet ? 28 : 24,
            ),
            onPressed: () async {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
              if (result == true) {
                _loadQuestionnaire();
              }
            },
            splashRadius: isTablet ? 28 : 24,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_currentQuestionnaire == null) {
      return const Center(
        child: Text('Erreur: Impossible de charger le questionnaire'),
      );
    }

    if (_showEndMessage) {
      return _buildEndMessageScreen();
    }

    return _buildQuestionScreen();
  }

  Widget _buildQuestionScreen() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final question = _currentQuestionnaire!.questions[_currentQuestionIndex];
    final isLastQuestion =
        _currentQuestionIndex == _currentQuestionnaire!.questions.length - 1;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              kToolbarHeight,
        ),
        child: IntrinsicHeight(
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 48.0 : 24.0,
                  vertical: isTablet ? 32.0 : 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1} / ${_currentQuestionnaire!.questions.length}',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (_currentQuestionIndex + 1) /
                            _currentQuestionnaire!.questions.length,
                        minHeight: isTablet ? 10 : 8,
                        backgroundColor: Colors.grey[200],
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 48 : 32),
              // Question widget
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 48.0 : 24.0,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: QuestionWidget(
                        question: question,
                        initialValue: _answers[question.id],
                        onAnswered: (value) {
                          setState(() => _answers[question.id] = value);
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 64 : 48),
              // Navigation buttons
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 48.0 : 24.0,
                  vertical: isTablet ? 32.0 : 24.0,
                ),
                child: Row(
                  children: [
                    // Back button (not visible on first question)
                    if (_currentQuestionIndex > 0)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _currentQuestionIndex--);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 20 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Précédent',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    if (_currentQuestionIndex > 0)
                      SizedBox(width: isTablet ? 24 : 16),
                    // Next/Submit button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 20 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                isLastQuestion ? 'Soumettre' : 'Suivant',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEndMessageScreen() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >= 600;
    final endMessage = _feedbackService.getEndMessage(_currentQuestionnaire!.id);

    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight - MediaQuery.of(context).padding.top - kToolbarHeight,
          ),
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 48.0 : 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Success icon with smiley
                      Container(
                        width: isTablet ? 160 : 120,
                        height: isTablet ? 160 : 120,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                        child: Center(
                          child: Text(
                            '😄',
                            style: TextStyle(
                              fontSize: isTablet ? 80 : 60,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isTablet ? 48 : 32),
                      // End message
                      Text(
                        endMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isTablet ? 32 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: isTablet ? 64 : 48),
                      // Countdown text
                      Text(
                        'La première question réapparaîtra dans 20 secondes...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
