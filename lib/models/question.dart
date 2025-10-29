// TODO Implement this library.
import 'package:flutter/foundation.dart';

enum QuestionType {
  starRating,    // 1-5 stars
  score,         // 1-10 score
  email,         // Email input
  phone,         // Phone input
  text,          // Free text
  singleChoice,  // Multiple choice
}

class Question {
  final String id;
  final String text;
  final QuestionType type;
  final bool isMandatory;
  final List<String>? choices; // For single choice questions
  final String? placeholder;
  final dynamic defaultValue; // Default value for the question

  Question({
    required this.id,
    required this.text,
    required this.type,
    this.isMandatory = true,
    this.choices,
    this.placeholder,
    this.defaultValue,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      type: _parseQuestionType(json['type'] as String),
      isMandatory: json['isMandatory'] as bool? ?? true,
      choices: List<String>.from(json['choices'] as List<dynamic>? ?? []),
      placeholder: json['placeholder'] as String?,
      defaultValue: json['defaultValue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type.toString().split('.').last,
      'isMandatory': isMandatory,
      'choices': choices,
      'placeholder': placeholder,
      'defaultValue': defaultValue,
    };
  }

  static QuestionType _parseQuestionType(String type) {
    return QuestionType.values.firstWhere(
      (e) => e.toString().split('.').last == type,
      orElse: () => QuestionType.text,
    );
  }
}

class Questionnaire {
  final String id;
  final String name;
  final List<Question> questions;
  final String? endMessage;

  Questionnaire({
    required this.id,
    required this.name,
    required this.questions,
    this.endMessage,
  });

  factory Questionnaire.fromJson(Map<String, dynamic> json) {
    return Questionnaire(
      id: json['id'] as String,
      name: json['name'] as String,
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      endMessage: json['endMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'questions': questions.map((q) => q.toJson()).toList(),
      'endMessage': endMessage,
    };
  }
}

class Answer {
  final String questionId;
  final dynamic value;
  final DateTime timestamp;

  Answer({
    required this.questionId,
    required this.value,
    required this.timestamp,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      questionId: json['questionId'] as String,
      value: json['value'],
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class FeedbackResponse {
  final String id;
  final String questionnaireId;
  final List<Answer> answers;
  final DateTime submittedAt;

  FeedbackResponse({
    required this.id,
    required this.questionnaireId,
    required this.answers,
    required this.submittedAt,
  });

  factory FeedbackResponse.fromJson(Map<String, dynamic> json) {
    return FeedbackResponse(
      id: json['id'] as String,
      questionnaireId: json['questionnaireId'] as String,
      answers: (json['answers'] as List<dynamic>?)
              ?.map((a) => Answer.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      submittedAt: DateTime.parse(json['submittedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionnaireId': questionnaireId,
      'answers': answers.map((a) => a.toJson()).toList(),
      'submittedAt': submittedAt.toIso8601String(),
    };
  }
}
