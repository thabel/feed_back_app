import 'package:flutter/material.dart';
import '../models/question.dart';

class QuestionWidget extends StatefulWidget {
  final Question question;
  final Function(dynamic) onAnswered;
  final dynamic initialValue;

  const QuestionWidget({
    Key? key,
    required this.question,
    required this.onAnswered,
    this.initialValue,
  }) : super(key: key);

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  late dynamic _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text with mandatory indicator
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.question.text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              if (widget.question.isMandatory)
                const Text(
                  '*',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 32),
          // Question-specific widgets
          _buildQuestionWidget(),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget() {
    final current = _currentValue;
    int toInt(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    String toStr(dynamic v) {
      if (v is String) return v;
      return v?.toString() ?? '';
    }

    switch (widget.question.type) {
      case QuestionType.starRating:
        return StarRatingWidget(
          initialValue: toInt(current),
          onChanged: (value) {
            setState(() => _currentValue = value);
            widget.onAnswered(value);
          },
        );
      case QuestionType.score:
        return ScoreWidget(
          initialValue: toInt(current),
          onChanged: (value) {
            setState(() => _currentValue = value);
            widget.onAnswered(value);
          },
        );
      case QuestionType.email:
        return EmailWidget(
          initialValue: toStr(current),
          onChanged: (value) {
            setState(() => _currentValue = value);
            widget.onAnswered(value);
          },
          isMandatory: widget.question.isMandatory,
        );
      case QuestionType.phone:
        return PhoneWidget(
          initialValue: toStr(current),
          onChanged: (value) {
            setState(() => _currentValue = value);
            widget.onAnswered(value);
          },
          isMandatory: widget.question.isMandatory,
        );
      case QuestionType.text:
        return TextInputWidget(
          initialValue: toStr(current),
          onChanged: (value) {
            setState(() => _currentValue = value);
            widget.onAnswered(value);
          },
          placeholder: widget.question.placeholder,
          isMandatory: widget.question.isMandatory,
        );
      case QuestionType.singleChoice:
        return SingleChoiceWidget(
          choices: widget.question.choices ?? [],
          initialValue: toStr(current),
          onChanged: (value) {
            setState(() => _currentValue = value);
            widget.onAnswered(value);
          },
        );
    }
  }
}

class StarRatingWidget extends StatefulWidget {
  final int initialValue;
  final Function(int) onChanged;

  const StarRatingWidget({
    Key? key,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  late int _rating;

  final List<String> _smileys = ['😞', '😟', '😐', '😊', '😄'];
  final List<String> _labels = ['Très mauvais', 'Mauvais', 'Neutre', 'Bon', 'Excellent'];

  @override
  void initState() {
    super.initState();
    _rating = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final iconSize = isMobile ? 31.0 : 70.0;
    final spacing = isMobile ? 8.0 : 16.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final ratingValue = index + 1;
          final isSelected = _rating == ratingValue;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: GestureDetector(
              onTap: () {
                setState(() => _rating = ratingValue);
                widget.onChanged(ratingValue);
              },
              child: Column(
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.3 : 0.9,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        _smileys[index],
                        style: TextStyle(fontSize: iconSize),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!isMobile)
                    Text(
                      _labels[index],
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: isSelected ? Colors.blue : Colors.grey[600],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class ScoreWidget extends StatefulWidget {
  final int initialValue;
  final Function(int) onChanged;

  const ScoreWidget({
    Key? key,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<ScoreWidget> createState() => _ScoreWidgetState();
}

class _ScoreWidgetState extends State<ScoreWidget> {
  late int _score;

  @override
  void initState() {
    super.initState();
    _score = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final crossAxisCount = isMobile ? 5 : 10;
    final gridHeight = isMobile ? 150.0 : 120.0;
    final fontSize = isMobile ? 16.0 : 20.0;

    return Column(
      children: [
        SizedBox(
          height: gridHeight,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: isMobile ? 6 : 10,
              mainAxisSpacing: isMobile ? 6 : 10,
            ),
            itemCount: 10,
            itemBuilder: (context, index) {
              final scoreValue = index + 1;
              final isSelected = _score == scoreValue;

              return GestureDetector(
                onTap: () {
                  setState(() => _score = scoreValue);
                  widget.onChanged(scoreValue);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: _score >= scoreValue
                        ? const Color(0xFF2196F3)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: Colors.blue, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      scoreValue.toString(),
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: _score >= scoreValue ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        if (_score > 0)
          Column(
            children: [
              Text(
                'Score sélectionné',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_score/10',
                style: TextStyle(
                  fontSize: isMobile ? 36 : 48,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class EmailWidget extends StatefulWidget {
  final String initialValue;
  final Function(String) onChanged;
  final bool isMandatory;

  const EmailWidget({
    Key? key,
    required this.initialValue,
    required this.onChanged,
    required this.isMandatory,
  }) : super(key: key);

  @override
  State<EmailWidget> createState() => _EmailWidgetState();
}

class _EmailWidgetState extends State<EmailWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'exemple@email.com',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          onChanged: (value) {
            widget.onChanged(value);
          },
        ),
        if (_controller.text.isNotEmpty && !_isValidEmail(_controller.text))
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Email invalide',
              style: TextStyle(color: Colors.red[700], fontSize: 14),
            ),
          ),
      ],
    );
  }
}

class PhoneWidget extends StatefulWidget {
  final String initialValue;
  final Function(String) onChanged;
  final bool isMandatory;

  const PhoneWidget({
    Key? key,
    required this.initialValue,
    required this.onChanged,
    required this.isMandatory,
  }) : super(key: key);

  @override
  State<PhoneWidget> createState() => _PhoneWidgetState();
}

class _PhoneWidgetState extends State<PhoneWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        hintText: '+33 6 12 34 56 78',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      onChanged: (value) {
        widget.onChanged(value);
      },
    );
  }
}

class TextInputWidget extends StatefulWidget {
  final String initialValue;
  final Function(String) onChanged;
  final String? placeholder;
  final bool isMandatory;

  const TextInputWidget({
    Key? key,
    required this.initialValue,
    required this.onChanged,
    this.placeholder,
    required this.isMandatory,
  }) : super(key: key);

  @override
  State<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: widget.placeholder ?? 'Entrez votre réponse',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      onChanged: (value) {
        widget.onChanged(value);
      },
    );
  }
}

class SingleChoiceWidget extends StatefulWidget {
  final List<String> choices;
  final String initialValue;
  final Function(String) onChanged;

  const SingleChoiceWidget({
    Key? key,
    required this.choices,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<SingleChoiceWidget> createState() => _SingleChoiceWidgetState();
}

class _SingleChoiceWidgetState extends State<SingleChoiceWidget> {
  late String _selectedChoice;

  @override
  void initState() {
    super.initState();
    _selectedChoice = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.choices
          .map(
            (choice) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedChoice = choice);
                  widget.onChanged(choice);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _selectedChoice == choice
                        ? Colors.blue[50]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedChoice == choice
                          ? Colors.blue
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedChoice == choice
                                ? Colors.blue
                                : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: _selectedChoice == choice
                            ? Center(
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        choice,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
