
import 'package:flutter/material.dart';

const Color primaryBlue = Color(0xFF0865E8);
const Color darkBlue = Color(0xFF07377D);
const Color lightBackground = Color(0xFFF3F9FF);
const Color borderBlue = Color(0xFFD8E9FF);
const Color textBlue = Color(0xFF0645A5);

class LmsSettingsScreen extends StatefulWidget {
  const LmsSettingsScreen({super.key});

  @override
  State<LmsSettingsScreen> createState() => _LmsSettingsScreenState();
}

class _LmsSettingsScreenState extends State<LmsSettingsScreen> {
  final _institutionController = TextEditingController(
    text: 'University Central Library & Information Center',
  );
  final _emailController = TextEditingController(
    text: 'library@univ.et',
  );
  final _phoneController = TextEditingController(
    text: '+251 11 123 4567',
  );
  final _addressController = TextEditingController(
    text: 'Addis Ababa, Ethiopia.',
  );
  final _academicYearController = TextEditingController(
    text: '2025 - 2026',
  );
  final _borrowingDaysController = TextEditingController(text: '14');
  final _maxBooksController = TextEditingController(text: '3');
  final _reservationDaysController = TextEditingController(text: '7');
  final _fineCapController = TextEditingController(text: '250');

  String dateFormat = 'YYYY-MM-DD';
  String timeFormat = '12 Hours (AM/PM)';
  String currency = 'ETB';
  TimeOfDay openingTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay closingTime = const TimeOfDay(hour: 17, minute: 0);

  final Map<String, bool> workingDays = {
    'Mon': true,
    'Tue': true,
    'Wed': true,
    'Thu': true,
    'Fri': true,
    'Sat': false,
    'Sun': false,
  };

  @override
  void dispose() {
    _institutionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _academicYearController.dispose();
    _borrowingDaysController.dispose();
    _maxBooksController.dispose();
    _reservationDaysController.dispose();
    _fineCapController.dispose();
    super.dispose();
  }

  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  Future<void> chooseTime(bool opening) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: opening ? openingTime : closingTime,
    );

    if (selected != null) {
      setState(() {
        if (opening) {
          openingTime = selected;
        } else {
          closingTime = selected;
        }
      });
    }
  }

  void saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Settings validated. Connect your database to save permanently.',
        ),
        backgroundColor: primaryBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              children: [
                _buildSidebar(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 1100;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPageTitle(),
                            const SizedBox(height: 18),
                            if (wide)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 7,
                                    child: _buildMainColumn(),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    flex: 3,
                                    child: _buildInformationColumn(),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  _buildMainColumn(),
                                  const SizedBox(height: 18),
                                  _buildInformationColumn(),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF07377D), Color(0xFF0865D9)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Library Management System',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                size: 29,
                color: Colors.white,
              ),
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 25),
          const CircleAvatar(
            radius: 19,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: primaryBlue,
              size: 27,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ms. Sara Ahmed',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Administrator',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(width: 14),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF07377D), Color(0xFF06418F)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 18),
          _navItem(Icons.home_rounded, 'Dashboard'),
          _navItem(Icons.settings_rounded, 'LMS Settings', selected: true),
          _navItem(Icons.people_alt_rounded, 'Staff Management'),
          _navItem(Icons.menu_book_rounded, 'Book Inventory'),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.layers_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Read More,\nLearn More,\nGrow More.',
                    style: TextStyle(
                      color: Colors.white,
                      height: 1.4,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String title, {
    bool selected = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Container(
        height: 49,
        decoration: BoxDecoration(
          color: selected ? primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            const SizedBox(width: 13),
            Icon(icon, color: Colors.white, size: 27),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageTitle() {
    return Row(
      children: [
        const Icon(
          Icons.settings_rounded,
          color: primaryBlue,
          size: 39,
        ),
        const SizedBox(width: 17),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LMS Settings',
                style: TextStyle(
                  color: textBlue,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Configure library rules, circulation settings, and system parameters.',
                style: TextStyle(
                  color: Color(0xFF5082C8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainColumn() {
    return Column(
      children: [
        _buildInstitutionCard(),
        const SizedBox(height: 13),
        _buildSystemSettingsCard(),
        const SizedBox(height: 13),
        _buildWorkingHoursCard(),
        const SizedBox(height: 13),
        _buildBottomCards(),
      ],
    );
  }

  Widget _buildInstitutionCard() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.account_balance_rounded,
            'Institution Information',
          ),
          const SizedBox(height: 16),
          _field(
            'Institution Name',
            _institutionController,
            required: true,
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _field(
                  'Contact Email',
                  _emailController,
                  required: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _field(
                  'Phone Number',
                  _phoneController,
                  required: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          _field(
            'Address',
            _addressController,
            required: true,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemSettingsCard() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.settings, 'System Settings'),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _field(
                  'Academic Year',
                  _academicYearController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _dropdownField(
                  'Date Format',
                  dateFormat,
                  ['YYYY-MM-DD', 'DD-MM-YYYY', 'MM/DD/YYYY'],
                  (value) => setState(() => dateFormat = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              const Expanded(
                child: SizedBox.shrink(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _dropdownField(
                  'Time Format',
                  timeFormat,
                  ['12 Hours (AM/PM)', '24 Hours'],
                  (value) => setState(() => timeFormat = value!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursCard() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.access_time_rounded, 'Working Hours'),
          const SizedBox(height: 17),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _timeField(
                  'Opening Time',
                  openingTime,
                  () => chooseTime(true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: _timeField(
                  'Closing Time',
                  closingTime,
                  () => chooseTime(false),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Working Days',
                      style: TextStyle(
                        color: textBlue,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 5,
                      runSpacing: 0,
                      children: workingDays.keys.map((day) {
                        return SizedBox(
                          width: 59,
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            controlAffinity:
                                ListTileControlAffinity.leading,
                            title: Text(
                              day,
                              style: const TextStyle(
                                fontSize: 11,
                                color: textBlue,
                              ),
                            ),
                            value: workingDays[day],
                            activeColor: primaryBlue,
                            onChanged: (value) {
                              setState(() {
                                workingDays[day] = value ?? false;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCards() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: _panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(Icons.menu_book_rounded, 'Library Limits'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _dropdownField(
                        'Maximum Borrowing Days',
                        _borrowingDaysController.text,
                        ['7', '10', '14', '21', '30'],
                        (value) {
                          setState(() {
                            _borrowingDaysController.text = value!;
                          });
                        },
                        required: true,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _field(
                        'Maximum Books Per Student',
                        _maxBooksController,
                        required: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        'Reservation Duration (Days)',
                        _reservationDaysController,
                        required: true,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _field(
                        'Fine Cap (per book)',
                        _fineCapController,
                        required: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _dropdownField(
                  'Currency',
                  currency,
                  ['ETB', 'USD', 'EUR'],
                  (value) => setState(() => currency = value!),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: _panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(
                  Icons.verified_user_rounded,
                  'System Actions',
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF5FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderBlue),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_rounded,
                        color: primaryBlue,
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Changes made here will apply to all users and affect library operations.',
                          style: TextStyle(
                            color: textBlue,
                            fontSize: 11,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton.icon(
                    onPressed: saveSettings,
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: const Text('Save Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInformationColumn() {
    return Column(
      children: [
        _panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(Icons.info_rounded, 'Quick Info'),
              const SizedBox(height: 14),
              const Text(
                'These settings control library working hours, borrowing limits, and general system behavior.',
                style: TextStyle(
                  color: Color(0xFF5082C8),
                  height: 1.7,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(Icons.access_time_filled, 'Last Updated'),
              const SizedBox(height: 15),
              const Text(
                'Jun 8, 2025   •   10:24 AM',
                style: TextStyle(
                  color: Color(0xFF5082C8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'by Admin',
                style: TextStyle(
                  color: Color(0xFF5082C8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderBlue),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080B65C9),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: primaryBlue, size: 25),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: textBlue,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool required = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, required),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
            color: textBlue,
            fontSize: 12,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: borderBlue),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: borderBlue),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(
                color: primaryBlue,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged, {
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, required),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          style: const TextStyle(
            color: textBlue,
            fontSize: 12,
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: textBlue,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: borderBlue),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: borderBlue),
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _fieldLabel(String label, bool required) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: textBlue,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        children: [
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _timeField(
    String label,
    TimeOfDay time,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, true),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: borderBlue),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    formatTime(time),
                    style: const TextStyle(
                      color: textBlue,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: primaryBlue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
