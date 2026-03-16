import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

// ─── Models ───────────────────────────────────────────────────────────────────
class _Technique {
  final String name;
  final String emoji;
  final String description;
  final Color color;
  final List<Color> gradient;
  final int inhale;   // seconds
  final int hold1;
  final int exhale;
  final int hold2;

  const _Technique({
    required this.name,
    required this.emoji,
    required this.description,
    required this.color,
    required this.gradient,
    required this.inhale,
    required this.hold1,
    required this.exhale,
    required this.hold2,
  });

  int get total => inhale + hold1 + exhale + hold2;
}

const _techniques = [
  _Technique(
    name: 'Box Breathing',
    emoji: '🟦',
    description: 'Used by Navy SEALs to stay calm under pressure.',
    color: Color(0xFF2196F3),
    gradient: [Color(0xFF1565C0), Color(0xFF42A5F5)],
    inhale: 4, hold1: 4, exhale: 4, hold2: 4,
  ),
  _Technique(
    name: '4-7-8 Calm',
    emoji: '🌙',
    description: 'Dr. Weil\'s method to reduce anxiety fast.',
    color: Color(0xFF7C7CF8),
    gradient: [Color(0xFF5E35B1), Color(0xFFAE9EF4)],
    inhale: 4, hold1: 7, exhale: 8, hold2: 0,
  ),
  _Technique(
    name: 'Deep Calm',
    emoji: '🌊',
    description: 'Slow deep breathing to activate the parasympathetic system.',
    color: Color(0xFF00897B),
    gradient: [Color(0xFF00695C), Color(0xFF4DB6AC)],
    inhale: 5, hold1: 2, exhale: 6, hold2: 1,
  ),
  _Technique(
    name: 'Energise',
    emoji: '⚡',
    description: 'Quick technique to boost energy and focus instantly.',
    color: Color(0xFFFF9800),
    gradient: [Color(0xFFE65100), Color(0xFFFFB74D)],
    inhale: 2, hold1: 0, exhale: 2, hold2: 0,
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────
class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with TickerProviderStateMixin {
  int _selectedTechnique = 0;
  bool _isRunning = false;
  int _sessionCount = 0;

  // Animation controllers
  late AnimationController _breathCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _ringScale;
  late Animation<double> _pulse;

  String _phase = 'Tap Start';
  int _phaseSeconds = 0;
  int _phaseIndex = 0; // 0=inhale,1=hold,2=exhale,3=hold2

  _Technique get _current => _techniques[_selectedTechnique];

  static const _phaseNames = ['Inhale', 'Hold', 'Exhale', 'Hold'];

  @override
  void initState() {
    super.initState();
    _breathCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _ringScale = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOutSine),
    );
    _pulse = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _start() {
    setState(() {
      _isRunning = true;
      _phaseIndex = 0;
      _phase = 'Inhale';
      _phaseSeconds = _current.inhale;
    });
    _runPhase();
  }

  void _stop() {
    _breathCtrl.stop();
    setState(() {
      _isRunning = false;
      _phase = 'Tap Start';
      _phaseIndex = 0;
    });
  }

  Future<void> _runPhase() async {
    if (!mounted || !_isRunning) return;

    final phases = [_current.inhale, _current.hold1, _current.exhale, _current.hold2];
    final idx = _phaseIndex % 4;
    final seconds = phases[idx];
    final name = _phaseNames[idx];

    if (seconds == 0) {
      // Skip zero-duration phases
      setState(() => _phaseIndex++);
      _maybeIncrementSession();
      _runPhase();
      return;
    }

    setState(() {
      _phase = name;
      _phaseSeconds = seconds;
    });

    HapticFeedback.lightImpact();

    // Animate ring
    if (idx == 0) {
      _breathCtrl.duration = Duration(seconds: seconds);
      _breathCtrl.forward(from: 0);
    } else if (idx == 2) {
      _breathCtrl.duration = Duration(seconds: seconds);
      _breathCtrl.reverse(from: 1);
    } else {
      _breathCtrl.stop();
    }

    // Countdown
    for (int i = seconds; i >= 0; i--) {
      if (!mounted || !_isRunning) return;
      setState(() => _phaseSeconds = i);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_isRunning) return;
    }

    setState(() => _phaseIndex++);
    _maybeIncrementSession();

    _runPhase();
  }

  void _maybeIncrementSession() {
    // Count one full cycle (4 phases = 1 session)
    if (_phaseIndex % 4 == 0 && _phaseIndex > 0) {
      setState(() => _sessionCount++);
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tech = _current;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      body: Stack(
        children: [
          // ── Gradient background ────────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 1.2,
                  colors: [
                    tech.color.withOpacity(0.25),
                    const Color(0xFF0F1923),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── AppBar ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white70, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text('Breathing Exercise',
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: tech.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: tech.color.withOpacity(0.4)),
                        ),
                        child: Text('$_sessionCount cycles',
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: tech.color)),
                      ),
                    ],
                  ),
                ),

                // ── Technique pills ───────────────────────────────────────
                SizedBox(
                  height: 56,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    itemCount: _techniques.length,
                    itemBuilder: (_, i) {
                      final t = _techniques[i];
                      final sel = _selectedTechnique == i;
                      return GestureDetector(
                        onTap: () {
                          if (!_isRunning) {
                            setState(() => _selectedTechnique = i);
                          }
                        },
                        child: AnimatedContainer(
                          duration: 250.ms,
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? t.color : Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel ? t.color : Colors.white.withOpacity(0.12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(t.emoji,
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(t.name,
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: sel
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: sel
                                          ? Colors.white
                                          : Colors.white54)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 4),

                // ── Description ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    tech.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.white54, height: 1.4),
                  ),
                ),

                const Spacer(),

                // ── Ring animation ────────────────────────────────────────
                AnimatedBuilder(
                  animation: Listenable.merge([_breathCtrl, _pulseCtrl]),
                  builder: (_, __) {
                    final scale = _isRunning ? _ringScale.value : _pulse.value * 0.55;
                    return SizedBox(
                      width: 280,
                      height: 280,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow ring
                          Container(
                            width: 240 * scale + 40,
                            height: 240 * scale + 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: tech.color.withOpacity(0.1 + scale * 0.15),
                                width: 1.5,
                              ),
                            ),
                          ),
                          // Main breathing ring
                          Container(
                            width: 240 * scale,
                            height: 240 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  tech.color.withOpacity(0.35),
                                  tech.color.withOpacity(0.08),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: tech.color.withOpacity(scale * 0.4),
                                  blurRadius: 40 * scale,
                                  spreadRadius: 5 * scale,
                                ),
                              ],
                            ),
                          ),
                          // Phase text
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _phase,
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (_isRunning) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '$_phaseSeconds',
                                  style: GoogleFonts.poppins(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w800,
                                    color: tech.color,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const Spacer(),

                // ── Phase guide pills ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _PhasePill('Inhale', '${tech.inhale}s', tech.color, _isRunning && _phaseIndex % 4 == 0),
                      if (tech.hold1 > 0)
                        _PhasePill('Hold', '${tech.hold1}s', Colors.white54, _isRunning && _phaseIndex % 4 == 1),
                      _PhasePill('Exhale', '${tech.exhale}s', tech.color.withOpacity(0.7), _isRunning && _phaseIndex % 4 == 2),
                      if (tech.hold2 > 0)
                        _PhasePill('Hold', '${tech.hold2}s', Colors.white54, _isRunning && _phaseIndex % 4 == 3),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Start/Stop button ─────────────────────────────────────
                GestureDetector(
                  onTap: _isRunning ? _stop : _start,
                  child: AnimatedContainer(
                    duration: 300.ms,
                    width: 200,
                    height: 58,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isRunning
                            ? [Colors.white24, Colors.white12]
                            : tech.gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: _isRunning
                          ? []
                          : [
                              BoxShadow(
                                color: tech.color.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isRunning
                                ? Icons.stop_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isRunning ? 'Stop' : 'Start',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhasePill extends StatelessWidget {
  final String label;
  final String duration;
  final Color color;
  final bool active;

  const _PhasePill(this.label, this.duration, this.color, this.active);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 300.ms,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.2) : Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? color.withOpacity(0.6) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: active ? color : Colors.white38,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
          Text(duration,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: active ? Colors.white : Colors.white38)),
        ],
      ),
    );
  }
}
