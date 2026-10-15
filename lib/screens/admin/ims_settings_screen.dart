
import 'package:flutter/material.dart';

class ImsSettingsScreen extends StatefulWidget {
  const ImsSettingsScreen({super.key});

  @override
  State<ImsSettingsScreen> createState() => _ImsSettingsScreenState();
}

class _ImsSettingsScreenState extends State<ImsSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _libraryName = TextEditingController(
    text: 'Central Library',
  );
  final _email = TextEditingController(
    text: 'library@example.com',
  );
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _maxBooks = TextEditingController(text: '5');
  final _loanDays = TextEditingController(text: '14');
  final _finePerDay = TextEditingController(text: '5');

  bool _dueDateNotifications = true;
  bool _overdueNotifications = true;
  bool _reservationNotifications = true;
  bool _autoRenewal = false;

  @override
  void dispose() {
    _libraryName.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _maxBooks.dispose();
    _loanDays.dispose();
    _finePerDay.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Settings validated. Connect the settings service to persist changes.',
        ),
      ),
    );
  }

  void _resetSettings() {
    setState(() {
      _libraryName.text = 'Central Library';
      _email.text = 'library@example.com';
      _phone.clear();
      _address.clear();
      _maxBooks.text = '5';
      _loanDays.text = '14';
      _finePerDay.text = '5';
      _dueDateNotifications = true;
      _overdueNotifications = true;
      _reservationNotifications = true;
      _autoRenewal = false;
    });
  }

  Widget _section({
    required String title,
    required String description,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7ECF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFEAF1FF),
                child: Icon(icon, color: const Color(0xFF0052CC)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(description,
                        style: const TextStyle(
                            color: Colors.blueGrey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool numeric = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType:
          numeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field is required';
            }
            if (numeric &&
                (int.tryParse(value) == null || int.parse(value) < 0)) {
              return 'Enter a valid non-negative number';
            }
            return null;
          },
    );
  }

  Widget _toggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
      value: value,
      activeThumbColor: const Color(0xFF0052CC),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LMS Settings',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF142B4A),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Configure library information, borrowing rules, and notifications.',
                  style: TextStyle(color: Colors.blueGrey),
                ),
                const SizedBox(height: 24),
                _section(
                  title: 'Library information',
                  description: 'Basic information about your library.',
                  icon: Icons.apartment_outlined,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth > 650;

                      final name = _field(
                        _libraryName,
                        'Library name',
                      );
                      final email = _field(
                        _email,
                        'Contact email',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                              .hasMatch(value.trim())) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      );
                      final phone = _field(_phone, 'Phone number');
                      final address = _field(_address, 'Address');

                      if (!wide) {
                        return Column(
                          children: [
                            name,
                            const SizedBox(height: 14),
                            email,
                            const SizedBox(height: 14),
                            phone,
                            const SizedBox(height: 14),
                            address,
                          ],
                        );
                      }

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: name),
                              const SizedBox(width: 16),
                              Expanded(child: email),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: phone),
                              const SizedBox(width: 16),
                              Expanded(child: address),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                _section(
                  title: 'Borrowing rules',
                  description:
                      'Set limits for book loans and overdue fines.',
                  icon: Icons.rule_folder_outlined,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth > 650;

                      final fields = [
                        _field(
                          _maxBooks,
                          'Maximum books per reader',
                          numeric: true,
                        ),
                        _field(
                          _loanDays,
                          'Loan period (days)',
                          numeric: true,
                        ),
                        _field(
                          _finePerDay,
                          'Fine per overdue day',
                          numeric: true,
                        ),
                      ];

                      if (!wide) {
                        return Column(
                          children: fields
                              .map((field) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 14),
                                    child: field,
                                  ))
                              .toList(),
                        );
                      }

                      return Row(
                        children: [
                          for (var i = 0; i < fields.length; i++) ...[
                            if (i > 0) const SizedBox(width: 14),
                            Expanded(child: fields[i]),
                          ],
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                _section(
                  title: 'Notifications',
                  description:
                      'Choose which library events should trigger notifications.',
                  icon: Icons.notifications_none,
                  child: Column(
                    children: [
                      _toggle(
                        'Due-date reminders',
                        'Notify readers before books are due.',
                        _dueDateNotifications,
                        (v) => setState(
                            () => _dueDateNotifications = v),
                      ),
                      _toggle(
                        'Overdue notifications',
                        'Notify readers when a book is overdue.',
                        _overdueNotifications,
                        (v) => setState(
                            () => _overdueNotifications = v),
                      ),
                      _toggle(
                        'Reservation updates',
                        'Notify readers about reservation status.',
                        _reservationNotifications,
                        (v) => setState(
                            () => _reservationNotifications = v),
                      ),
                      _toggle(
                        'Automatic loan renewal',
                        'Enable automatic renewal where library rules allow it.',
                        _autoRenewal,
                        (v) => setState(() => _autoRenewal = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _resetSettings,
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Reset form'),
                    ),
                    FilledButton.icon(
                      onPressed: _saveSettings,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
