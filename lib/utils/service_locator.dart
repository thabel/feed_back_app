import '../services/feedback_service.dart';

/// Service locator for dependency injection
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() {
    return _instance;
  }

  ServiceLocator._internal();

  late FeedbackService _feedbackService;

  /// Initialize all services
  void setup() {
    _feedbackService = FeedbackService();
  }

  /// Get FeedbackService instance
  FeedbackService get feedbackService => _feedbackService;

  /// Reset all services (useful for testing)
  void reset() {
    _feedbackService = FeedbackService();
  }
}

/// Global service locator instance
final serviceLocator = ServiceLocator();
