import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/student_model_service.dart';
import '../models/question_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentModelService>(
      builder: (ctx, studentService, _) {
        final student = studentService.student;
        if (student == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final stats = studentService.getStudyStats();

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar ve isim
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF9C94FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            student.name.isNotEmpty
                                ? student.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        student.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        student.levelTitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildProfileStat('⭐', 'Seviye', '${student.level}'),
                          const SizedBox(width: 24),
                          _buildProfileStat('🔥', 'Seri', '${student.streak} gün'),
                          const SizedBox(width: 24),
                          _buildProfileStat('💎', 'XP', '${student.xp}'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // İstatistikler
                _buildSectionTitle('📊 İstatistikler'),
                const SizedBox(height: 12),
                _buildStatsGrid(stats),

                const SizedBox(height: 24),

                // Konu hakimiyetleri
                _buildSectionTitle('🗺️ Konu Haritası'),
                const SizedBox(height: 12),
                ...defaultTopics.map((topic) {
                  final mastery = student.topicMastery[topic.id] ?? 0.0;
                  return _buildTopicMasteryCard(topic, mastery);
                }),

                const SizedBox(height: 24),

                // Başarılar
                _buildSectionTitle('🏆 Başarılar'),
                const SizedBox(height: 12),
                _buildAchievements(student),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileStat(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF2D2D2D),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('📝', 'Toplam Soru', '${stats['totalQuestions'] ?? 0}', const Color(0xFF6C63FF)),
        _buildStatCard('✅', 'Doğru Cevap', '${stats['correctAnswers'] ?? 0}', const Color(0xFF43A047)),
        _buildStatCard('🎯', 'Başarı Oranı', '${((stats['successRate'] ?? 0.0) * 100).toInt()}%', const Color(0xFFFF9800)),
        _buildStatCard('💪', 'Güçlü Konu', '${(stats['strongTopics'] as List?)?.length ?? 0}', const Color(0xFF0288D1)),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildTopicMasteryCard(Topic topic, double mastery) {
    final color = mastery > 0.7
        ? const Color(0xFF43A047)
        : mastery > 0.4
            ? const Color(0xFFFF9800)
            : const Color(0xFF6C63FF);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(topic.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      topic.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${(mastery * 100).toInt()}%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: mastery,
                    backgroundColor: Colors.grey.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(student) {
    final badges = [
      if (student.totalCorrect >= 1) {'emoji': '🎯', 'name': 'İlk Doğru', 'desc': 'İlk doğru cevap'},
      if (student.totalCorrect >= 10) {'emoji': '⭐', 'name': 'Yükselen Yıldız', 'desc': '10 doğru cevap'},
      if (student.streak >= 3) {'emoji': '🔥', 'name': 'Ateşli', 'desc': '3 günlük seri'},
      if (student.level >= 5) {'emoji': '🚀', 'name': 'Seviye 5', 'desc': 'Seviye 5\'e ulaştı'},
      if (student.totalAttempts >= 50) {'emoji': '💪', 'name': 'Azimli', 'desc': '50 soru çözüldü'},
    ];

    if (badges.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: Text(
            '🌱 Çalışmaya devam et, rozetler kazanacaksın!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: badges.map((badge) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(badge['emoji']!, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 6),
              Text(
                badge['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                badge['desc']!,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
