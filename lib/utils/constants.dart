import 'package:flutter/material.dart';

class AppConstants {
  // Admin
  static const String ADMIN_PASSWORD = '1234';

  // Timers
  static const Duration AUTO_RESET_DURATION = Duration(minutes: 5);
  static const Duration API_CALL_DELAY = Duration(milliseconds: 800);

  // Colors
  static const Color PRIMARY_COLOR = Colors.blue;
  static const Color SUCCESS_COLOR = Colors.green;
  static const Color ERROR_COLOR = Colors.red;
  static const Color BACKGROUND_COLOR = Colors.white;

  // Text Styles
  static const TextStyle HEADING_LARGE = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color(0xFF333333),
  );

  static const TextStyle HEADING_MEDIUM = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF333333),
  );

  static const TextStyle BODY_TEXT = TextStyle(
    fontSize: 16,
    color: Color(0xFF666666),
  );

  static const TextStyle BUTTON_TEXT = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Messages
  static const String ERROR_MANDATORY_FIELD = 'Cette question est obligatoire';
  static const String ERROR_INVALID_EMAIL = 'Veuillez entrer un email valide';
  static const String ERROR_INVALID_PASSWORD = 'Mot de passe incorrect';
  static const String SUCCESS_QUESTIONNAIRE_CHANGED =
      'Questionnaire changé avec succès';

  // Button Labels
  static const String BUTTON_NEXT = 'Suivant';
  static const String BUTTON_PREVIOUS = 'Précédent';
  static const String BUTTON_SUBMIT = 'Soumettre';
  static const String BUTTON_APPLY = 'Appliquer';
  static const String BUTTON_LOGOUT = 'Déconnexion';
  static const String BUTTON_VALIDATE = 'Valider';

  // Screen Titles
  static const String TITLE_SETTINGS = 'Paramètres';
  static const String TITLE_ADMIN_ACCESS = 'Accès Administrateur';
  static const String TITLE_WELCOME_ADMIN = 'Bienvenue Administrateur';
  static const String TITLE_CHANGE_QUESTIONNAIRE = 'Changer le Questionnaire';
  static const String TITLE_FEEDBACK_CENTER = 'Feedback Center';

  // Placeholder Texts
  static const String PLACEHOLDER_EMAIL = 'exemple@email.com';
  static const String PLACEHOLDER_PHONE = '+33 6 12 34 56 78';
  static const String PLACEHOLDER_TEXT = 'Entrez votre réponse';
  static const String PLACEHOLDER_FEEDBACK = 'Partagez vos commentaires ici...';

  // Padding and Spacing
  static const double PADDING_SMALL = 8.0;
  static const double PADDING_MEDIUM = 16.0;
  static const double PADDING_LARGE = 24.0;
  static const double SPACING_SMALL = 8.0;
  static const double SPACING_MEDIUM = 16.0;
  static const double SPACING_LARGE = 32.0;
  static const double SPACING_XL = 48.0;

  // Border Radius
  static const double BORDER_RADIUS_SMALL = 8.0;
  static const double BORDER_RADIUS_MEDIUM = 12.0;
  static const double BORDER_RADIUS_LARGE = 16.0;

  // Icon Sizes
  static const double ICON_SIZE_SMALL = 24.0;
  static const double ICON_SIZE_MEDIUM = 48.0;
  static const double ICON_SIZE_LARGE = 60.0;
  static const double ICON_SIZE_XLARGE = 80.0;

  // Star Rating
  static const int STAR_RATING_MAX = 5;
  static const double STAR_SIZE = 60.0;

  // Score
  static const int SCORE_MAX = 10;
  static const int SCORE_GRID_COLUMNS = 5;
}
