import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'education_hub_screen.dart';
import '../../../core/constants/app_colors.dart';

class TopicDetailScreen extends StatefulWidget {
  final EducationTopic topic;

  const TopicDetailScreen({Key? key, required this.topic}) : super(key: key);

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  int? _selectedAnswer;
  int _currentQuizIndex = 0;
  bool _quizAnswered = false;
  int _score = 0;
  bool _quizComplete = false;

  void _selectAnswer(int index) {
    if (_quizAnswered) return;
    setState(() {
      _selectedAnswer = index;
      _quizAnswered = true;
      if (index == widget.topic.quiz[_currentQuizIndex]['answer']) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuizIndex < widget.topic.quiz.length - 1) {
      setState(() {
        _currentQuizIndex++;
        _selectedAnswer = null;
        _quizAnswered = false;
      });
    } else {
      setState(() => _quizComplete = true);
    }
  }

  void _resetQuiz() {
    setState(() {
      _currentQuizIndex = 0;
      _selectedAnswer = null;
      _quizAnswered = false;
      _score = 0;
      _quizComplete = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: topic.color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [topic.color, topic.color.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 100, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(topic.icon, color: Colors.white.withOpacity(0.8), size: 40),
                        const SizedBox(height: 8),
                        Text(topic.title,
                            style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: topic.color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: topic.color.withOpacity(0.2)),
                      ),
                      child: Text(
                        topic.description,
                        style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textMain, height: 1.6),
                      ),
                    ).animate().fadeIn(duration: 400.ms),

                    const SizedBox(height: 28),

                    // Key Takeaways
                    Text('Key Takeaways 📖',
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold))
                        .animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 16),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: topic.bulletPoints.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(color: topic.color.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3)),
                              ],
                            ),
                            child: Text(
                              topic.bulletPoints[index],
                              style: GoogleFonts.poppins(fontSize: 14, height: 1.5, color: AppColors.textMain),
                            ),
                          ).animate().fadeIn(duration: 350.ms, delay: (index * 80).ms).slideX(begin: 0.1),
                        );
                      },
                    ),

                    // Quiz Section
                    if (topic.quiz.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Text('Quick Quiz 🎯',
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold))
                          .animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 4),
                      Text('Test what you learned!',
                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500)),
                      const SizedBox(height: 16),
                      _buildQuizSection(topic),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizSection(EducationTopic topic) {
    if (_quizComplete) {
      return _buildQuizResult(topic);
    }

    final question = topic.quiz[_currentQuizIndex];
    final options = question['options'] as List;
    final correctAnswer = question['answer'] as int;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: topic.color.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          Row(
            children: [
              Text('Q${_currentQuizIndex + 1} of ${topic.quiz.length}',
                  style: GoogleFonts.poppins(fontSize: 12, color: topic.color, fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentQuizIndex + 1) / topic.quiz.length,
                    backgroundColor: topic.color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(topic.color),
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(question['q'] as String,
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, height: 1.4)),
          const SizedBox(height: 16),
          ...List.generate(options.length, (i) {
            Color optColor = Colors.grey.shade100;
            Color textColor = AppColors.textMain;
            if (_quizAnswered) {
              if (i == correctAnswer) {
                optColor = Colors.green.shade50;
                textColor = Colors.green.shade800;
              } else if (i == _selectedAnswer && i != correctAnswer) {
                optColor = Colors.red.shade50;
                textColor = Colors.red.shade800;
              }
            } else if (_selectedAnswer == i) {
              optColor = topic.color.withOpacity(0.1);
              textColor = topic.color;
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _selectAnswer(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: optColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _quizAnswered && i == correctAnswer
                          ? Colors.green
                          : (_quizAnswered && i == _selectedAnswer
                              ? Colors.red
                              : Colors.grey.shade200),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: textColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + i), // A, B, C, D
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(options[i] as String,
                            style: GoogleFonts.poppins(fontSize: 14, color: textColor, fontWeight: FontWeight.w500)),
                      ),
                      if (_quizAnswered && i == correctAnswer)
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      if (_quizAnswered && i == _selectedAnswer && i != correctAnswer)
                        const Icon(Icons.cancel, color: Colors.red, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (_quizAnswered) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: topic.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  _currentQuizIndex < topic.quiz.length - 1 ? 'Next Question →' : 'See Results 🎉',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildQuizResult(EducationTopic topic) {
    final percentage = (_score / topic.quiz.length * 100).round();
    final emoji = percentage >= 80 ? '🌟' : (percentage >= 50 ? '😊' : '💪');
    final message = percentage >= 80 ? 'Excellent work!' : (percentage >= 50 ? 'Good effort!' : 'Keep learning!');

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [topic.color.withOpacity(0.12), topic.color.withOpacity(0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: topic.color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 56)).animate().scale(begin: const Offset(0.5, 0.5), duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: topic.color)),
          const SizedBox(height: 8),
          Text('You got $_score out of ${topic.quiz.length} correct ($percentage%)',
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _resetQuiz,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('Try Again', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: topic.color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }
}
