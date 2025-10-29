// EXEMPLE D'INTÉGRATION BACKEND
// Ce fichier montre comment intégrer un vrai backend au lieu des mocks

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class FeedbackServiceWithBackend {
  // Configuration du backend
  static const String BASE_URL = 'https://your-backend-api.com/api';
  static const String GET_QUESTIONNAIRES = '$BASE_URL/questionnaires';
  static const String GET_ACTIVE_QUESTIONNAIRE =
      '$BASE_URL/questionnaires/active';
  static const String SET_ACTIVE_QUESTIONNAIRE =
      '$BASE_URL/questionnaires/active';
  static const String SUBMIT_FEEDBACK = '$BASE_URL/feedback';

  final http.Client _httpClient;
  String _currentQuestionnaireId = '';

  FeedbackServiceWithBackend({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Récupérer la liste des questionnaires
  Future<List<Map<String, String>>> getQuestionnairesList() async {
    try {
      final response = await _httpClient
          .get(Uri.parse(GET_QUESTIONNAIRES))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((q) => {
                  'id': q['id'] as String,
                  'name': q['name'] as String,
                })
            .toList();
      } else {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des questionnaires: $e');
    }
  }

  /// Récupérer le questionnaire actif
  Future<Questionnaire?> getCurrentQuestionnaire() async {
    try {
      final response = await _httpClient
          .get(Uri.parse(GET_ACTIVE_QUESTIONNAIRE))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Questionnaire.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Erreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement du questionnaire: $e');
    }
  }

  /// Changer le questionnaire actif (fonction admin)
  Future<bool> setActiveQuestionnaire(String questionnaireId) async {
    try {
      final response = await _httpClient
          .post(
            Uri.parse(SET_ACTIVE_QUESTIONNAIRE),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'questionnaireId': questionnaireId}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _currentQuestionnaireId = questionnaireId;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Erreur lors du changement de questionnaire: $e');
    }
  }

  /// Soumettre une réponse de feedback
  Future<bool> submitFeedback(FeedbackResponse response) async {
    try {
      final response_http = await _httpClient
          .post(
            Uri.parse(SUBMIT_FEEDBACK),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(response.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      if (response_http.statusCode == 200 ||
          response_http.statusCode == 201) {
        return true;
      } else {
        throw Exception('Erreur: ${response_http.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la soumission du feedback: $e');
    }
  }

  /// Valider les réponses
  bool validateAnswers(
    List<Question> questions,
    Map<String, dynamic> answers,
  ) {
    for (var question in questions) {
      if (question.isMandatory) {
        final answer = answers[question.id];

        if (answer == null || answer == '' || answer == 0) {
          return false;
        }

        if (question.type == QuestionType.email && answer is String) {
          if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(answer)) {
            return false;
          }
        }
      }
    }
    return true;
  }
}

// NOTES D'INTÉGRATION:
// 1. Remplacer les appels à FeedbackService par FeedbackServiceWithBackend
// 2. Ajouter l'authentification si nécessaire (tokens, API keys)
// 3. Implémenter les retry en cas d'erreur réseau
// 4. Ajouter le caching pour les questionnaires
// 5. Gérer les erreurs de connexion gracieusement
// 6. Ajouter les logs pour le debugging
//
// EXEMPLE D'ENDPOINT BACKEND ATTENDU:
//
// GET /api/questionnaires
// Réponse: [
//   {
//     "id": "q1",
//     "name": "Satisfaction Générale",
//     "questions": [...],
//     "endMessage": "Merci pour vos retours!"
//   }
// ]
//
// GET /api/questionnaires/active
// Réponse: {
//   "id": "q1",
//   "name": "Satisfaction Générale",
//   "questions": [...],
//   "endMessage": "Merci pour vos retours!"
// }
//
// POST /api/questionnaires/active
// Body: {"questionnaireId": "q2"}
// Réponse: {"success": true}
//
// POST /api/feedback
// Body: {
//   "id": "uuid",
//   "questionnaireId": "q1",
//   "answers": [...],
//   "submittedAt": "2024-01-01T12:00:00Z"
// }
// Réponse: {"success": true, "feedbackId": "uuid"}
