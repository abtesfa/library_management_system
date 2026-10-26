import 'package:flutter/material.dart';
import '../../models/staff.dart';


class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _settings = SystemSettings();
  late TextEditingController _nameController;
  late TextEditingController _openTimeController;
  late TextEditingController _closeTimeController;
  late TextEditingController _borrowDaysController;
  late TextEditingController _fineController;
  bool _savedToast = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _settings.libraryName);
    _openTimeController = TextEditingController(text: _settings.openingTime);
    _closeTimeController = TextEditingController(text: _settings.closingTime);
    _borrowDaysController = TextEditingController(text: _settings.maxBorrowDays.toString());
    _fineController = TextEditingController(text: _settings.finePerDay.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _openTimeController.dispose();
    _closeTimeController.dispose();
    _borrowDaysController.dispose();
    _fineController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    setState(() => _savedToast = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('LMS policy & operating hours saved successfully!'),
        backgroundColor: Color(0xFF059669),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.settings, color: Color(0xFF0052CC), size: 24),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LMS Settings',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    'Configure library working hours, loan limits, and fine policies',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Cards Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: General & Working Hours
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildCard(
                      title: 'Library Information & Working Hours',
                      icon: Icons.access_time,
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Library Name',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _openTimeController,
                                decoration: const InputDecoration(
                                  labelText: 'Opening Time',
                                  prefixIcon: Icon(Icons.wb_sunny_outlined, size: 18),
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextField(
                                controller: _closeTimeController,
                                decoration: const InputDecoration(
                                  labelText: 'Closing Time',
                                  prefixIcon: Icon(Icons.nights_stay_outlined, size: 18),
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildCard(
                      title: 'Circulation Policies & Limits',
                      icon: Icons.rule_folder_outlined,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _borrowDaysController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Max Loan Duration (Days)',
                                  suffixText: 'Days',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextField(
                                controller: _fineController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Overdue Fine (Per Day)',
                                  prefixText: '\ETB ',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Column 2: Quick Summary & Save
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Policy Summary',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 14),
                      _summaryTile('Standard Borrow Period', '14 Days'),
                      _summaryTile('Daily Late Fee', '\ETB 0.50 / day'),
                      _summaryTile('Active Working Hours', '08:00 AM - 08:00 PM'),
                      
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: _saveSettings,
                          icon: const Icon(Icons.save, size: 18),
                          label: const Text('Save LMS Settings'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0052CC),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0052CC), size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _summaryTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}
