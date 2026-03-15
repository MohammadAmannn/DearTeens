import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  final List<String> _commonSymptoms = [
    'Cramps', 'Headache', 'Bloating', 'Fatigue', 'Acne', 'Mood Swings', 'Backache'
  ];

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _periodStart : (_periodEnd ?? _periodStart);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.pink,
              onPrimary: Colors.white,
              onSurface: Colors.black,
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
          if (_periodEnd != null && _periodEnd!.isBefore(_periodStart)) {
            _periodEnd = null; // Reset invalid end date
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
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Period Log'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Period Dates',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Start Date
              InkWell(
                onTap: () => _selectDate(context, true),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.pink.shade100, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Started On', style: TextStyle(fontSize: 16)),
                      Text(
                        '${_periodStart.toLocal()}'.split(' ')[0], 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.pink),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // End Date
              InkWell(
                onTap: () => _selectDate(context, false),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.pink.shade100, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ended On (Optional)', style: TextStyle(fontSize: 16)),
                      Text(
                        _periodEnd == null ? 'Select Date' : '${_periodEnd!.toLocal()}'.split(' ')[0], 
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold, 
                          color: _periodEnd == null ? Colors.grey : Colors.pink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              const Text(
                'Symptoms',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _commonSymptoms.map((symptom) {
                  final isSelected = _selectedSymptoms.contains(symptom);
                  return ChoiceChip(
                    label: Text(symptom),
                    selected: isSelected,
                    selectedColor: Colors.pink.withOpacity(0.2),
                    side: BorderSide(
                      color: isSelected ? Colors.pink : Colors.grey.shade300,
                    ),
                    onSelected: (_) => _toggleSymptom(symptom),
                  );
                }).toList(),
              ),

              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveLog,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Save Log'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
