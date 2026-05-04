import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question_model.dart';
import '../models/student_model.dart';
import '../services/ai_service.dart';
import '../services/student_model_service.dart';

class StudyScreen extends StatefulWidget {
  final Topic topic;
  const StudyScreen({super.key, required this.topic});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> with TickerProviderStateMixin {
  Question? _currentQuestion;
  AIResponse? _aiResponse;
  int? _selectedOption;
  bool _answered = false;
  bool _isCorrect = false;
  int _attemptCount = 0;
  int _correctStreak = 0;
  bool _showStory = false;
  bool _showAlternative = false;
  String _storyIntro = '';

  // BUG FIX 1: Hata durumunu takip eden state değişkenleri eklendi
  String? _questionLoadError;
  String? _aiResponseError;

  late AnimationController _shakeController;
  late AnimationController _celebrateController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _celebrateAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _celebrateController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _celebrateAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _celebrateController, curve: Curves.elasticOut),
    );
    _loadStoryAndQuestion();
  }

  Future<void> _loadStoryAndQuestion() async {
    // BUG FIX 1: Yeniden deneme öncesi hata state'i sıfırla
    if (mounted) setState(() => _questionLoadError = null);

    try {
      final aiService = context.read<AIService>();
      final studentService = context.read<StudentModelService>();
      final student = studentService.student;

      final story = await aiService.generateStoryIntro(widget.topic.name);
      if (mounted) setState(() => _storyIntro = story);

      await _generateNextQuestion(student);
    } catch (e) {
      // BUG FIX 1: Hata yakalanıyor ve state'e yazılıyor
      if (mounted) {
        setState(() => _questionLoadError = 'Soru yüklenemedi: ${e.toString()}');
      }
    }
  }

  Future<void> _generateNextQuestion(StudentModel? student) async {
    if (student == null) return;

    // BUG FIX 1: Soru yükleme hatasını temizle
    if (mounted) setState(() => _questionLoadError = null);

    try {
      final aiService = context.read<AIService>();
      final studentService = context.read<StudentModelService>();

      final difficulty = studentService.getRecommendedDifficulty(widget.topic.id);
      final subtopic = widget.topic.subtopics.isNotEmpty
          ? widget.topic.subtopics[_correctStreak % widget.topic.subtopics.length]
          : widget.topic.name;

      final question = await aiService.generateQuestion(
        topic: widget.topic.id,
        subtopic: subtopic,
        difficulty: difficulty,
        student: student,
      );

      if (mounted) {
        setState(() {
          _currentQuestion = question;
          _selectedOption = null;
          _answered = false;
          _isCorrect = false;
          _attemptCount = 0;
          _aiResponse = null;
          _aiResponseError = null;
          _showStory = false;
          _showAlternative = false;
        });
      }
    } catch (e) {
      // BUG FIX 1: Soru üretme hatası state'e yazılıyor
      if (mounted) {
        setState(() => _questionLoadError = 'Yeni soru oluşturulamadı: ${e.toString()}');
      }
    }
  }

  Future<void> _handleAnswer(int index) async {
    if (_answered && _isCorrect) return;
    if (_currentQuestion == null) return;

    setState(() {
      _selectedOption = index;
      _attemptCount++;
    });

    final correct = index == _currentQuestion!.correctIndex;

    if (correct) {
      setState(() {
        _answered = true;
        _isCorrect = true;
        _correctStreak++;
      });
      _celebrateController.forward(from: 0);

      final studentService = context.read<StudentModelService>();
      await studentService.recordAttempt(QuestionAttempt(
        topic: widget.topic.id,
        question: _currentQuestion!.text,
        userAnswer: _currentQuestion!.options[index],
        isCorrect: true,
        attemptNumber: _attemptCount,
        timeSpentSeconds: 30,
      ));
    } else {
      _shakeController.forward(from: 0);

      // BUG FIX 2: AI yanıt hatasını temizle, yüklemeyi göster
      setState(() {
        _answered = true;
        _isCorrect = false;
        _aiResponse = null;
        _aiResponseError = null;
      });

      try {
        final aiService = context.read<AIService>();
        final studentService = context.read<StudentModelService>();
        final response = await aiService.analyzeWrongAnswer(
          question: _currentQuestion!,
          userAnswer: _currentQuestion!.options[index],
          student: studentService.student!,
          attemptNumber: _attemptCount,
        );

        if (mounted) {
          setState(() => _aiResponse = response);
        }
      } catch (e) {
        // BUG FIX 2: AI açıklama hatası state'e yazılıyor — sonsuz spinner yok
        if (mounted) {
          setState(() => _aiResponseError = 'Açıklama yüklenemedi. Tekrar dene.');
        }
      }

      await context.read<StudentModelService>().recordAttempt(QuestionAttempt(
        topic: widget.topic.id,
        question: _currentQuestion!.text,
        userAnswer: _currentQuestion!.options[index],
        isCorrect: false,
        attemptNumber: _attemptCount,
        timeSpentSeconds: 30,
      ));
    }
  }

  void _tryAgain() {
    setState(() {
      _answered = false;
      _selectedOption = null;
      _aiResponse = null;
      _aiResponseError = null;
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _celebrateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EFFE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(widget.topic.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              widget.topic.name,
              style: const TextStyle(
                color: Color(0xFF2D2D2D),
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '$_correctStreak',
                  style: const TextStyle(
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<AIService>(
        builder: (context, aiService, _) {
          // BUG FIX 1: Hata durumu kontrolü — sonsuz yükleme yerine hata ekranı
          if (_questionLoadError != null) {
            return _buildErrorState(_questionLoadError!, onRetry: _loadStoryAndQuestion);
          }
          if (aiService.isLoading && _currentQuestion == null) {
            return _buildLoadingState();
          }
          if (_currentQuestion == null) {
            return _buildLoadingState();
          }
          return _buildStudyContent(aiService);
        },
      ),
    );
  }

  // BUG FIX 1: Soru yükleme hatası için hata ekranı widget'ı
  Widget _buildErrorState(String message, {required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😕', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF555555),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🤖', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 20),
          const CircularProgressIndicator(color: Color(0xFF6C63FF)),
          const SizedBox(height: 16),
          Text(
            _storyIntro.isNotEmpty ? _storyIntro : 'AI öğretmenin düşünüyor...',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyContent(AIService aiService) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currentQuestion!.storyContext.isNotEmpty) ...[
            _buildStoryCard(),
            const SizedBox(height: 16),
          ],
          _buildQuestionCard(),
          const SizedBox(height: 20),
          ...List.generate(
            _currentQuestion!.options.length,
            (i) => _buildOptionCard(i),
          ),
          const SizedBox(height: 20),
          if (_answered) _buildResultArea(aiService),
        ],
      ),
    );
  }

  Widget _buildStoryCard() {
    return GestureDetector(
      onTap: () => setState(() => _showStory = !_showStory),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
        ),
        child: Row(
          children: [
            const Text('📖', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hikaye Modu',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  if (_showStory)
                    Text(
                      _currentQuestion!.storyContext,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    )
                  else
                    const Text(
                      'Dokunarak hikaye modunu aç',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _currentQuestion!.subtopic,
                  style: const TextStyle(
                    color: Color(0xFF6C63FF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  _currentQuestion!.difficulty,
                  (_) => const Text('⭐', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _currentQuestion!.text,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              height: 1.5,
              color: Color(0xFF2D2D2D),
            ),
          ),
          if (_currentQuestion!.examProbability > 0.7) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6584).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '🎯 Sınavda çıkma ihtimali: %${(_currentQuestion!.examProbability * 100).toInt()}',
                style: const TextStyle(
                  color: Color(0xFFFF6584),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionCard(int index) {
    final isSelected = _selectedOption == index;
    final isCorrect = index == _currentQuestion!.correctIndex;
    final showResult = _answered;

    Color bgColor = Colors.white;
    Color borderColor = Colors.transparent;
    Color textColor = const Color(0xFF2D2D2D);

    if (showResult) {
      if (isCorrect) {
        bgColor = const Color(0xFFE8F5E9);
        borderColor = const Color(0xFF4CAF50);
        textColor = const Color(0xFF2E7D32);
      } else if (isSelected && !isCorrect) {
        bgColor = const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFF44336);
        textColor = const Color(0xFFC62828);
      }
    } else if (isSelected) {
      bgColor = const Color(0xFFEDE7FF);
      borderColor = const Color(0xFF6C63FF);
      textColor = const Color(0xFF4527A0);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (_, child) {
          double offset = 0;
          if (isSelected && !isCorrect && _shakeController.isAnimating) {
            offset = 8 * (0.5 - (_shakeAnimation.value - 0.5).abs()) * 2;
          }
          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
        child: GestureDetector(
          onTap: () => _handleAnswer(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: borderColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      showResult && isCorrect
                          ? '✅'
                          : showResult && isSelected && !isCorrect
                              ? '❌'
                              : ['A', 'B', 'C', 'D'][index],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _currentQuestion!.options[index],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultArea(AIService aiService) {
    if (_isCorrect) {
      return _buildCorrectResult();
    } else {
      return _buildWrongResult(aiService);
    }
  }

  Widget _buildCorrectResult() {
    return ScaleTransition(
      scale: _celebrateAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF43A047), Color(0xFF76D275)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('🎉', style: TextStyle(fontSize: 36)),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harika!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '+30 XP kazandın!',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _currentQuestion!.explanation,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final studentService = context.read<StudentModelService>();
                  await _generateNextQuestion(studentService.student);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF43A047),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Sonraki Soru ➡️',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWrongResult(AIService aiService) {
    // BUG FIX 2: AI yanıt hatası için hata mesajı göster — sonsuz spinner yok
    if (_aiResponseError != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF44336).withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Text('😞', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              _aiResponseError!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFFC62828)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _tryAgain,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF6C63FF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('🔄 Tekrar Dene'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // AI açıklamasını tekrar yüklemeyi dene
                      if (_selectedOption == null || _currentQuestion == null) return;
                      setState(() => _aiResponseError = null);
                      try {
                        final response = await context.read<AIService>().analyzeWrongAnswer(
                          question: _currentQuestion!,
                          userAnswer: _currentQuestion!.options[_selectedOption!],
                          student: context.read<StudentModelService>().student!,
                          attemptNumber: _attemptCount,
                        );
                        if (mounted) setState(() => _aiResponse = response);
                      } catch (e) {
                        if (mounted) {
                          setState(() => _aiResponseError = 'Açıklama yüklenemedi. Tekrar dene.');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('🤖 AI\'dan İste'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // BUG FIX 2: _aiResponse null ise spinner göster (bu geçici bir durum, hata değil)
    if (_aiResponse == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: Color(0xFF6C63FF)),
              SizedBox(height: 12),
              Text('🤖 AI öğretmenin açıklama yazıyor...'),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Text('🤖', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _aiResponse!.encouragement,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4527A0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '📚 Açıklama',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            _aiResponse!.explanation,
            style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF424242)),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => setState(() => _showAlternative = !_showAlternative),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFD54F)),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Farklı bir açıklamayı dene',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                  Icon(
                    _showAlternative ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (_showAlternative) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDE7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _aiResponse!.alternativeExplanation,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
            ),
          ],
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => setState(() => _showStory = !_showStory),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Text('🎮', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  const Text(
                    'Hikaye modunda anlat',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const Spacer(),
                  Icon(_showStory ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (_showStory) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _aiResponse!.storyMode,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _tryAgain,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                '🔄 Tekrar Dene',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
