import 'package:flutter/material.dart';
import '../models/session.dart';
import '../utils/constants.dart';

class ScheduleScreen extends StatefulWidget {
  final List<Session> sessions;
  final VoidCallback onDataChanged;

  const ScheduleScreen({
    super.key,
    required this.sessions,
    required this.onDataChanged,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // Track which day is selected (null = show all)
  int? _selectedDayIndex;

  // Track week offset: 0 = this week, 1 = next week, -1 = last week
  int _weekOffset = 0;

  /// Get the Monday of the displayed week
  DateTime _getWeekStart() {
    final today = DateTime.now();
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    return DateTime(
      thisWeekStart.year,
      thisWeekStart.month,
      thisWeekStart.day + (_weekOffset * 7),
    );
  }

  /// Validates text input - allows letters, numbers, spaces, basic punctuation
  String? _validateName(String value, String fieldName) {
    if (value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    final validPattern = RegExp(r"^[a-zA-Z0-9\s\-\.\'\:\,\(\)]+$");
    if (!validPattern.hasMatch(value.trim())) {
      return '$fieldName contains invalid characters';
    }
    // Must contain at least one letter (no pure numbers like "123")
    if (!RegExp(r'[a-zA-Z]').hasMatch(value.trim())) {
      return '$fieldName must contain at least one letter';
    }
    return null;
  }

  /// Checks if a session has completely ended (end time + 10 min buffer passed)
  bool _hasSessionEnded(Session session) {
    final sessionEnd = DateTime(
      session.date.year, session.date.month, session.date.day,
      session.endTime.hour, session.endTime.minute,
    ).add(const Duration(minutes: 10));
    return DateTime.now().isAfter(sessionEnd);
  }

  /// Checks if a session has started
  bool _hasSessionStarted(Session session) {
    final sessionStart = DateTime(
      session.date.year, session.date.month, session.date.day,
      session.startTime.hour, session.startTime.minute,
    );
    return DateTime.now().isAfter(sessionStart);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final weekStart = _getWeekStart();

    final weekDays = List.generate(
      7, (i) => weekStart.add(Duration(days: i)),
    );

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final weekEnd = weekDays.last;
    final weekLabel =
        '${monthNames[weekStart.month - 1]} ${weekStart.day} - '
        '${monthNames[weekEnd.month - 1]} ${weekEnd.day}, ${weekEnd.year}';

    return Scaffold(
      body: Column(
        children: [
          // WEEK NAVIGATION BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: ALUColors.navy,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: ALUColors.gold),
                  onPressed: () {
                    setState(() {
                      _weekOffset--;
                      _selectedDayIndex = null;
                    });
                  },
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _weekOffset = 0;
                      _selectedDayIndex = null;
                    });
                  },
                  child: Column(
                    children: [
                      Text(weekLabel,
                          style: const TextStyle(
                              color: ALUColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      Text(
                        _weekOffset == 0
                            ? 'This Week'
                            : 'Tap to go to this week',
                        style: TextStyle(
                          color: _weekOffset == 0
                              ? ALUColors.gold
                              : ALUColors.lightGrey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: ALUColors.gold),
                  onPressed: () {
                    setState(() {
                      _weekOffset++;
                      _selectedDayIndex = null;
                    });
                  },
                ),
              ],
            ),
          ),

          // ===== TAPPABLE DAY SELECTOR =====
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            color: ALUColors.darkBlue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final day = weekDays[index];
                final isToday = day.day == today.day &&
                    day.month == today.month &&
                    day.year == today.year;
                final isSelected = _selectedDayIndex == index;
                final daySessionCount = widget.sessions.where((s) {
                  return s.date.year == day.year &&
                      s.date.month == day.month &&
                      s.date.day == day.day;
                }).length;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDayIndex =
                          _selectedDayIndex == index ? null : index;
                    });
                  },
                  child: Column(
                    children: [
                      Text(dayNames[index],
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected || isToday
                                ? ALUColors.gold
                                : ALUColors.lightGrey,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          )),
                      const SizedBox(height: 4),
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ALUColors.gold
                              : (isToday
                                  ? ALUColors.gold.withAlpha(50)
                                  : Colors.transparent),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isToday || isSelected
                                ? ALUColors.gold
                                : Colors.transparent,
                          ),
                        ),
                        child: Center(
                          child: Text('${day.day}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? ALUColors.navy
                                    : (isToday
                                        ? ALUColors.gold
                                        : ALUColors.white),
                              )),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (daySessionCount > 0)
                        Container(width: 6, height: 6,
                            decoration: const BoxDecoration(
                                color: ALUColors.gold,
                                shape: BoxShape.circle))
                      else
                        const SizedBox(height: 6),
                    ],
                  ),
                );
              }),
            ),
          ),

          //SESSION LIST
          Expanded(child: _buildSessionList(weekDays)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ALUColors.gold,
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add, color: ALUColors.navy),
      ),
    );
  }

  //SESSION LIST grouped by day
  Widget _buildSessionList(List<DateTime> weekDays) {
    final fullDayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final List<Widget> dayWidgets = [];
    final startIndex = _selectedDayIndex ?? 0;
    final endIndex = _selectedDayIndex != null ? _selectedDayIndex! + 1 : 7;

    for (int i = startIndex; i < endIndex; i++) {
      final day = weekDays[i];
      final daySessions = widget.sessions.where((s) {
        return s.date.year == day.year &&
            s.date.month == day.month &&
            s.date.day == day.day;
      }).toList();

      daySessions.sort((a, b) {
        final aMin = a.startTime.hour * 60 + a.startTime.minute;
        final bMin = b.startTime.hour * 60 + b.startTime.minute;
        return aMin.compareTo(bMin);
      });

      if (daySessions.isNotEmpty || _selectedDayIndex != null) {
        dayWidgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '${fullDayNames[i]}, ${monthNames[day.month - 1]} ${day.day}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ALUColors.gold),
            ),
          ),
        );

        if (daySessions.isEmpty) {
          dayWidgets.add(const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Card(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                        child: Text('No sessions on this day',
                            style: TextStyle(color: ALUColors.lightGrey))))),
          ));
        } else {
          for (final session in daySessions) {
            dayWidgets.add(Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _buildSessionCard(session),
            ));
          }
        }
      }
    }

    if (dayWidgets.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: ALUColors.lightGrey),
            SizedBox(height: 16),
            Text('No sessions this week',
                style: TextStyle(fontSize: 18, color: ALUColors.lightGrey)),
            SizedBox(height: 8),
            Text('Tap + to schedule a session',
                style: TextStyle(color: ALUColors.lightGrey)),
          ],
        ),
      );
    }

    return ListView(children: dayWidgets);
  }

  //SESSION CARD
  Widget _buildSessionCard(Session session) {
    final timeStr =
        '${Session.formatTime(session.startTime)} - ${Session.formatTime(session.endTime)}';
    final hasStarted = _hasSessionStarted(session);
    final hasEnded = _hasSessionEnded(session);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP ROW: Time + status badge + menu
            Row(
              children: [
                Text(timeStr,
                    style: const TextStyle(
                        color: ALUColors.gold, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                // Show status badge
                if (hasEnded)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ALUColors.lightGrey.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Ended',
                        style: TextStyle(
                            fontSize: 10, color: ALUColors.lightGrey)),
                  )
                else if (hasStarted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ALUColors.green.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('In Progress',
                        style: TextStyle(
                            fontSize: 10, color: ALUColors.green)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ALUColors.gold.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Upcoming',
                        style:
                            TextStyle(fontSize: 10, color: ALUColors.gold)),
                  ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      color: ALUColors.lightGrey, size: 20),
                  onSelected: (value) {
                    if (value == 'edit') {
                      // Warn if editing a past session
                      if (hasEnded) {
                        _showEditPastWarning(context, session);
                      } else {
                        _showAddEditDialog(context, session: session);
                      }
                    } else if (value == 'delete') {
                      _confirmDelete(context, session);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit')
                        ])),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete, size: 18, color: ALUColors.red),
                          SizedBox(width: 8),
                          Text('Delete',
                              style: TextStyle(color: ALUColors.red))
                        ])),
                  ],
                ),
              ],
            ),

            // SESSION TITLE
            Text(session.title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ALUColors.white)),
            const SizedBox(height: 4),

            // TYPE + LOCATION
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ALUColors.gold.withAlpha(50),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(session.sessionType,
                      style: const TextStyle(
                          fontSize: 11, color: ALUColors.gold)),
                ),
                if (session.location.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.location_on,
                      size: 14, color: ALUColors.lightGrey),
                  const SizedBox(width: 2),
                  Text(session.location,
                      style: const TextStyle(
                          fontSize: 12, color: ALUColors.lightGrey)),
                ],
              ],
            ),

            const SizedBox(height: 8),
            const Divider(color: ALUColors.lightGrey, height: 1),
            const SizedBox(height: 8),

            //SMART ATTENDANCE TOGGLE
            _buildAttendanceRow(session, hasStarted, hasEnded),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRow(
      Session session, bool hasStarted, bool hasEnded) {
    // CASE 1: Session hasn't started yet
    if (!hasStarted) {
      return Row(
        children: [
          const Text('Attendance: ',
              style: TextStyle(color: ALUColors.lightGrey, fontSize: 13)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ALUColors.navy,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ALUColors.lightGrey.withAlpha(100)),
            ),
            child: const Text('Available after session starts',
                style: TextStyle(fontSize: 11, color: ALUColors.lightGrey)),
          ),
        ],
      );
    }

    // CASE 2 & 3: Session started or ended - show toggles
    return Row(
      children: [
        const Text('Attendance: ',
            style: TextStyle(color: ALUColors.lightGrey, fontSize: 13)),
        const Spacer(),
        _buildAttendanceButton(
          label: 'Present',
          isSelected: session.isPresent == true,
          color: ALUColors.green,
          onTap: () {
            final newValue = session.isPresent == true ? null : true;
            // If session ended, ask for confirmation
            if (hasEnded) {
              _confirmLateAttendance(
                  context, session, newValue, 'Present');
            } else {
              setState(() => session.isPresent = newValue);
              widget.onDataChanged();
            }
          },
        ),
        const SizedBox(width: 8),
        _buildAttendanceButton(
          label: 'Absent',
          isSelected: session.isPresent == false,
          color: ALUColors.red,
          onTap: () {
            final newValue = session.isPresent == false ? null : false;
            if (hasEnded) {
              _confirmLateAttendance(
                  context, session, newValue, 'Absent');
            } else {
              setState(() => session.isPresent = newValue);
              widget.onDataChanged();
            }
          },
        ),
      ],
    );
  }

  /// Shows confirmation dialog when marking attendance after session ended
  void _confirmLateAttendance(BuildContext context, Session session,
      bool? newValue, String label) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: ALUColors.darkBlue,
          title: const Text('Late Attendance Update',
              style: TextStyle(color: ALUColors.white)),
          content: Text(
            'This session has already ended. Are you sure you want to '
            '${newValue == null ? "clear" : "mark as $label"}?',
            style: const TextStyle(color: ALUColors.lightGrey),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() => session.isPresent = newValue);
                widget.onDataChanged();
                Navigator.pop(dialogContext);
              },
              child: const Text('Yes, update'),
            ),
          ],
        );
      },
    );
  }

  /// Shows warning before editing a past session
  void _showEditPastWarning(BuildContext context, Session session) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: ALUColors.darkBlue,
          title: const Text('Edit Past Session',
              style: TextStyle(color: ALUColors.white)),
          content: const Text(
            'This session has already ended. Are you sure you want to edit it?',
            style: TextStyle(color: ALUColors.lightGrey),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _showAddEditDialog(context, session: session);
              },
              child: const Text('Edit anyway'),
            ),
          ],
        );
      },
    );
  }

  /// Attendance toggle button widget
  Widget _buildAttendanceButton({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? ALUColors.white : color,
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }

  // ADD/EDIT SESSION DIALOG with validation
  void _showAddEditDialog(BuildContext context, {Session? session}) {
    final titleController =
        TextEditingController(text: session?.title ?? '');
    final locationController =
        TextEditingController(text: session?.location ?? '');

    DateTime selectedDate = session?.date ?? DateTime.now();
    TimeOfDay selectedStartTime =
        session?.startTime ?? const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay selectedEndTime =
        session?.endTime ?? const TimeOfDay(hour: 10, minute: 0);
    String selectedType = session?.sessionType ?? 'Class';

    final isEditing = session != null;
    String? titleError;

    final sessionTypes = [
      'Class', 'Mastery Session', 'Study Group', 'PSL Meeting'
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: ALUColors.darkBlue,
              title: Text(
                isEditing ? 'Edit Session' : 'New Session',
                style: const TextStyle(color: ALUColors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // SESSION TITLE with validation
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Session Title *',
                        hintText: 'e.g. Software Engineering',
                        errorText: titleError,
                      ),
                      style: const TextStyle(color: ALUColors.white),
                      onChanged: (_) {
                        if (titleError != null) {
                          setDialogState(() => titleError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // DATE PICKER
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Date',
                          style: TextStyle(color: ALUColors.lightGrey)),
                      subtitle: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: const TextStyle(
                            color: ALUColors.white, fontSize: 16),
                      ),
                      trailing: const Icon(Icons.calendar_today,
                          color: ALUColors.gold),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 30)),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                    ),

                    // START TIME
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Start Time',
                          style: TextStyle(color: ALUColors.lightGrey)),
                      subtitle: Text(
                        Session.formatTime(selectedStartTime),
                        style: const TextStyle(
                            color: ALUColors.white, fontSize: 16),
                      ),
                      trailing: const Icon(Icons.access_time,
                          color: ALUColors.gold),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: dialogContext,
                          initialTime: selectedStartTime,
                        );
                        if (picked != null) {
                          setDialogState(() => selectedStartTime = picked);
                        }
                      },
                    ),

                    // END TIME
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('End Time',
                          style: TextStyle(color: ALUColors.lightGrey)),
                      subtitle: Text(
                        Session.formatTime(selectedEndTime),
                        style: const TextStyle(
                            color: ALUColors.white, fontSize: 16),
                      ),
                      trailing: const Icon(Icons.access_time,
                          color: ALUColors.gold),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: dialogContext,
                          initialTime: selectedEndTime,
                        );
                        if (picked != null) {
                          setDialogState(() => selectedEndTime = picked);
                        }
                      },
                    ),

                    // LOCATION (optional - no validation needed)
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location (optional)',
                        hintText: 'e.g. Room 204',
                      ),
                      style: const TextStyle(color: ALUColors.white),
                    ),
                    const SizedBox(height: 12),

                    // SESSION TYPE
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration:
                          const InputDecoration(labelText: 'Session Type'),
                      dropdownColor: ALUColors.darkBlue,
                      items: sessionTypes.map((type) {
                        return DropdownMenuItem(
                            value: type,
                            child: Text(type,
                                style: const TextStyle(
                                    color: ALUColors.white)));
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(
                            () => selectedType = value ?? 'Class');
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Validate title
                    final tError =
                        _validateName(titleController.text, 'Session title');
                    if (tError != null) {
                      setDialogState(() => titleError = tError);
                      return;
                    }

                    // Validate end time > start time
                    final startMin = selectedStartTime.hour * 60 +
                        selectedStartTime.minute;
                    final endMin =
                        selectedEndTime.hour * 60 + selectedEndTime.minute;
                    if (endMin <= startMin) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('End time must be after start time'),
                            backgroundColor: ALUColors.red),
                      );
                      return;
                    }

                    if (isEditing) {
                      session.title = titleController.text.trim();
                      session.date = selectedDate;
                      session.startTime = selectedStartTime;
                      session.endTime = selectedEndTime;
                      session.location = locationController.text.trim();
                      session.sessionType = selectedType;
                    } else {
                      widget.sessions.add(Session(
                        title: titleController.text.trim(),
                        date: selectedDate,
                        startTime: selectedStartTime,
                        endTime: selectedEndTime,
                        location: locationController.text.trim(),
                        sessionType: selectedType,
                      ));
                    }

                    widget.onDataChanged();
                    Navigator.pop(dialogContext);
                  },
                  child: Text(isEditing ? 'Save' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  //DELETE CONFIRMATION
  void _confirmDelete(BuildContext context, Session session) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: ALUColors.darkBlue,
          title: const Text('Delete Session',
              style: TextStyle(color: ALUColors.white)),
          content: Text(
            'Are you sure you want to delete "${session.title}"?',
            style: const TextStyle(color: ALUColors.lightGrey),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel')),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: ALUColors.red),
              onPressed: () {
                widget.sessions.removeWhere((s) => s.id == session.id);
                widget.onDataChanged();
                Navigator.pop(dialogContext);
              },
              child: const Text('Delete',
                  style: TextStyle(color: ALUColors.white)),
            ),
          ],
        );
      },
    );
  }
}
