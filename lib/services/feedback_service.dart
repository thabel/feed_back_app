import 'dart:async';
import '../models/question.dart';

class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();

  factory FeedbackService() {
    return _instance;
  }

  FeedbackService._internal();

  // Mock questionnaires from "backend"
  final Map<String, Questionnaire> _questionnaires = {
    'q1': Questionnaire(
      id: 'q1',
      name: 'Satisfaction Générale',
      questions: [
        Question(
          id: 'q1_1',
          text: 'Êtes-vous satisfait de votre visite?',
          type: QuestionType.starRating,
          isMandatory: true,
        ),
        Question(
          id: 'q1_2',
          text: 'Quel score donnez-vous à notre service?',
          type: QuestionType.score,
          isMandatory: true,
        ),
        Question(
          id: 'q1_3',
          text: 'Avez-vous des commentaires?',
          type: QuestionType.text,
          isMandatory: false,
          placeholder: 'Partagez vos commentaires ici...',
        ),
        Question(
          id: 'q1_4',
          text: 'Votre email',
          type: QuestionType.email,
          isMandatory: false,
        ),
        Question(
          id: 'q1_5',
          text: 'Votre téléphone',
          type: QuestionType.phone,
          isMandatory: false,
        ),
      ],
      endMessage: 'Merci pour vos retours! Votre avis nous est précieux.',
    ),
    'q2': Questionnaire(
      id: 'q2',
      name: 'Expérience Magasin',
      questions: [
        Question(
          id: 'q2_1',
          text: 'La propreté du magasin',
          type: QuestionType.starRating,
          isMandatory: true,
        ),
        Question(
          id: 'q2_2',
          text: 'Courtoisie du personnel',
          type: QuestionType.score,
          isMandatory: true,
        ),
        Question(
          id: 'q2_3',
          text: 'Qualité des produits',
          type: QuestionType.starRating,
          isMandatory: true,
        ),
        Question(
          id: 'q2_4',
          text: 'Reviendriez-vous dans notre magasin?',
          type: QuestionType.singleChoice,
          isMandatory: true,
          choices: ['Oui, définitivement', 'Peut-être', 'Non'],
        ),
        Question(
          id: 'q2_5',
          text: 'Votre email pour un suivi',
          type: QuestionType.email,
          isMandatory: false,
        ),
      ],
      endMessage: 'Au revoir! À bientôt dans notre magasin!',
    ),
    'q3': Questionnaire(
      id: 'q3',
      name: 'Évaluation Rapide',
      questions: [
        Question(
          id: 'q3_1',
          text: 'Globalement, comment décrivez-vous votre expérience?',
          type: QuestionType.starRating,
          isMandatory: true,
        ),
        Question(
          id: 'q3_2',
          text: 'Avez-vous trouvé ce que vous recherchiez?',
          type: QuestionType.singleChoice,
          isMandatory: true,
          choices: ['Oui', 'Non', 'Partiellement'],
        ),
      ],
      endMessage: 'Merci de nous avoir évalués!',
    ),
  };

  // Current active questionnaire
  String _currentQuestionnaireId = 'q1';

  // Getter for current questionnaire ID
  String get currentQuestionnaireId => _currentQuestionnaireId;

  // Get all questionnaire names
  Future<List<Map<String, String>>> getQuestionnairesList() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _questionnaires.values
        .map((q) => {'id': q.id, 'name': q.name})
        .toList();
  }

  // Get current active questionnaire
  Future<Questionnaire?> getCurrentQuestionnaire() async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));

    return _questionnaires[_currentQuestionnaireId];
  }

  // Change active questionnaire (admin function)
  Future<bool> setActiveQuestionnaire(String questionnaireId) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (_questionnaires.containsKey(questionnaireId)) {
      _currentQuestionnaireId = questionnaireId;
      return true;
    }
    return false;
  }

  // Submit feedback response
  Future<bool> submitFeedback(FeedbackResponse response) async {
    // Simulate API call delay and processing
    await Future.delayed(const Duration(milliseconds: 1500));

    // In real app, this would send data to backend
    print('Feedback submitted: ${response.id}');
    print('Questionnaire: ${response.questionnaireId}');
    print('Answers count: ${response.answers.length}');

    return true;
  }

  // Validate answers (check mandatory questions)
  bool validateAnswers(
    List<Question> questions,
    Map<String, dynamic> answers,
  ) {
    for (var question in questions) {
      if (question.isMandatory) {
        final answer = answers[question.id];

        // Check if answer exists and is not empty
        if (answer == null || answer == '' || answer == 0) {
          return false;
        }

        // Validate email format if needed
        if (question.type == QuestionType.email && answer is String) {
          if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(answer)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  // Get end message for questionnaire
  String getEndMessage(String questionnaireId) {
    final questionnaire = _questionnaires[questionnaireId];
    return questionnaire?.endMessage ?? 'Merci!';
  }
}
