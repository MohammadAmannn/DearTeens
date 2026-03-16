import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/period_provider.dart';

class AddLogScreen extends ConsumerStatefulWidget {
  const AddLogScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends ConsumerState<AddLogScreen> {
  DateTime _periodStart = DateTime.now();
  DateTime? _periodEnd;
  final List<String> _selectedSymptoms = [];
  bool _isLoading = false;
  String? _selectedFlow = 'Medium';

  static const List<Map<String, dynamic>> _symptomOptions = [
    {'name': 'Cramps', 'emoji': '😣', 'color': Color(0xFFE91E63)},
    {'name': 'Headache', 'emoji': '🤕', 'color': Color(0xFF9C27B0)},
    {'name': 'Bloating', 'emoji': '🫧', 'color': Color(0xFF2196F3)},
    {'name': 'Fatigue', 'emoji': '😴', 'color': Color(0xFF607D8B)},
    {'name': 'Acne', 'emoji': '😓', 'color': Color(0xFFFF9800)},
    {'name': 'Mood Swings', 'emoji': '🎭', 'color': Color(0xFF7C7CF8)},
    {'name': 'Backache', 'emoji': '🔙', 'color': Color(0xFF795548)},
    {'name': 'Nausea', 'emoji': '🤢', 'color': Color(0xFF4CAF50)},
    {'name': 'Breast Pain', 'emoji': '💧', 'color': Color(0xFFE91E63)},
    {'name': 'Cravings', 'emoji': '🍫', 'color': Color(0xFF795548)},
    {'name': 'Insomnia', 'emoji': '🌙', 'color': Color(0xFF3F51B5)},
    {'name': 'Dizziness', 'emoji': '💫', 'color': Color(0xFFFF5722)},
  ];

  static const List<Map<String, dynamic>> _flowLevels = [
    {'name': 'Light', 'emoji': '💧', 'color': Color(0xFFFFCDD2)},
    {'name': 'Medium', 'emoji': '💧💧', 'color': Color(0xFFEF9A9A)},
    {'name': 'Heavy', 'emoji': '💧💧💧', 'color': Color(0xFFE91E63)},
  ];

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate =
        isStart ? _periodStart : (_periodEnd ?? _periodStart);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate:
          DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE91E63),
              onPrimary: Colors.white,
              onSurface: Colors.black,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _periodStart = picked;
          if (_periodEnd != null &&
              _periodEnd!.isBefore(_periodStart)) {
            _periodEnd = null;
          }
        } else {
          _periodEnd = picked;
        }
      });
    }
  }

  void _toggleSymptom(String symptom) {
    setState(() {
      if (_selectedSymptoms.contains(symptom)) {
        _selectedSymptoms.remove(symptom);
      } else {
        _selectedSymptoms.add(symptom);
      }
    });
  }

  Future<void> _saveLog() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(periodProvider).addCycleLog(
            periodStart: _periodStart,
            periodEnd: _periodEnd,
            symptoms: _selectedSymptoms,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: Colors.white),
                const SizedBox(width: 8),
                Text('Period log saved! 🌸',
                    style: GoogleFonts.poppins(
                        color: Colors.white)),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Log Period',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textMain,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Step 1: Period Dates ──────────────────
                    _buildSectionHeader('1', 'Period Dates', Icons.calendar_month_rounded),
                    const SizedBox(height: 14),
                    _buildDateSelector(
                      label: 'Start Date',
                      date: _periodStart,
                      icon: Icons.play_arrow_rounded,
                      color: const Color(0xFFE91E63),
                      onTap: () => _selectDate(context, true),
                    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1),
                    const SizedBox(height: 10),
                    _buildDateSelector(
                      label: 'End Date (Optional)',
                      date: _periodEnd,
                      icon: Icons.stop_rounded,
                      color: const Color(0xFF7C7CF8),
                      onTap: () => _selectDate(context, false),
                      placeholder: 'Still ongoing? Skip this',
                    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideX(begin: 0.1),

                    // ── Step 2: Flow Level ───────────────────
                    const SizedBox(height: 28),
                    _buildSectionHeader('2', 'Flow Level', Icons.water_drop_rounded),
                    const SizedBox(height: 14),
                    Row(
                      children: _flowLevels.asMap().entries.map((entry) {
                        final flow = entry.value;
                        final isSelected =
                            _selectedFlow == flow['name'];
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(
                                () => _selectedFlow = flow['name'] as String),
                            child: AnimatedContainer(
                              duration: const Duration(
                                  milliseconds: 200),
                              margin: EdgeInsets.only(
                                  right: entry.key < 2 ? 10 : 0),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (flow['color'] as Color)
                                        .withOpacity(0.15)
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? (flow['color'] as Color)
                                      : AppColors.cardBorder,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: (flow['color']
                                                  as Color)
                                              .withOpacity(0.2),
                                          blurRadius: 10,
                                        )
                                      ]
                                    : null,
                              ),
                              child: Column(
                                children: [
                                  Text(flow['emoji'] as String,
                                      style: const TextStyle(
                                          fontSize: 18)),
                                  const SizedBox(height: 6),
                                  Text(flow['name'] as String,
                                      style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? flow['color']
                                                  as Color
                                              : AppColors
                                                  .textSecondary)),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(
                              duration: 300.ms,
                              delay: (entry.key * 80).ms),
                        );
                      }).toList(),
                    ),

                    // ── Step 3: Symptoms ─────────────────────
                    const SizedBox(height: 28),
                    _buildSectionHeader(
                        '3', 'Symptoms', Icons.healing_rounded),
                    const SizedBox(height: 6),
                    Text(
                      'Select all that apply',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textLight),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _symptomOptions
                          .asMap()
                          .entries
                          .map((entry) {
                        final symptom = entry.value;
                        final isSelected = _selectedSymptoms
                            .contains(symptom['name']);
                        return GestureDetector(
                          onTap: () => _toggleSymptom(
                              symptom['name'] as String),
                          child: AnimatedContainer(
                            duration: const Duration(
                                milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (symptom['color'] as Color)
                                      .withOpacity(0.12)
                                  : Colors.white,
                              borderRadius:
                                  BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? (symptom['color']
                                        as Color)
                                    : AppColors.cardBorder,
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: (symptom['color']
                                                as Color)
                                            .withOpacity(0.15),
                                        blurRadius: 8,
                                      )
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    symptom['emoji'] as String,
                                    style: const TextStyle(
                                        fontSize: 14)),
                                const SizedBox(width: 6),
                                Text(
                                  symptom['name'] as String,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? symptom['color']
                                            as Color
                                        : AppColors
                                            .textSecondary,
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 4),
                                  Icon(Icons.check_circle,
                                      color: symptom['color']
                                          as Color,
                                      size: 14),
                                ],
                              ],
                            ),
                          ).animate().fadeIn(
                              duration: 200.ms,
                              delay: (entry.key * 30).ms),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ── Save Button ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveLog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5))
                        : Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const Icon(
                                  Icons.check_rounded,
                                  size: 20),
                              const SizedBox(width: 8),
                              Text('Save Period Log',
                                  style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight:
                                          FontWeight.w700)),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      String number, String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFFFF6B9A)]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(number,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: const Color(0xFFE91E63), size: 20),
        const SizedBox(width: 6),
        Text(title,
            style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain)),
      ],
    );
  }

  Widget _buildDateSelector({
    required String label,
    DateTime? date,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? placeholder,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: date != null
                  ? color.withOpacity(0.3)
                  : AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textLight)),
                  Text(
                    date != null
                        ? _formatDate(date)
                        : (placeholder ?? 'Select date'),
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: date != null
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: date != null
                          ? color
                          : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.calendar_today_rounded,
                color: color.withOpacity(0.4), size: 18),
          ],
        ),
      ),
    );
  }
}
