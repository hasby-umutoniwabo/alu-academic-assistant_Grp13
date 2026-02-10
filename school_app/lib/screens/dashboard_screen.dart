import 'package:flutter/material.dart';
import '../models/assignment.dart';
import '../models/session.dart';
import '../utils/constants.dart';

class DashboardScreen extends StatelessWidget {
  final List<Assignment> assignments;
  final List<Session> sessions;

  const DashboardScreen({
    super.key,
    required this.assignments,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // ===== CALCULATE ACADEMIC WEEK =====
    final semesterStart = DateTime(2026, 1, 26);
    final daysSinceStart = todayDate.difference(semesterStart).inDays;
    final weekNumber = daysSinceStart >= 0 ? (daysSinceStart ~/ 7) + 1 : 1;

    // Upcoming assignments (due within 7 days, not completed)
    final upcomingAssignments = assignments.where((a) {
      final dueDate = DateTime(a.dueDate.year, a.dueDate.month, a.dueDate.day);
      final daysUntilDue = dueDate.difference(todayDate).inDays;
      return daysUntilDue >= 0 && daysUntilDue <= 7 && !a.isCompleted;
    }).toList();
    upcomingAssignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    // Today's sessions
    final todaySessions = sessions.where((s) {
      return s.date.year == today.year &&
          s.date.month == today.month &&
          s.date.day == today.day;
    }).toList();
    todaySessions.sort((a, b) {
      final aMin = a.startTime.hour * 60 + a.startTime.minute;
      final bMin = b.startTime.hour * 60 + b.startTime.minute;
      return aMin.compareTo(bMin);
    });

    // Attendance calculation
    final recordedSessions = sessions
        .where((s) => s.isPresent != null)
        .toList();
    final presentCount = recordedSessions
        .where((s) => s.isPresent == true)
        .length;
    final absentCount = recordedSessions
        .where((s) => s.isPresent == false)
        .length;
    final attendancePercent = recordedSessions.isEmpty
        ? 100.0
        : (presentCount / recordedSessions.length) * 100;

    final pendingCount = assignments.where((a) => !a.isCompleted).length;
    final isAtRisk = attendancePercent < 75 && recordedSessions.isNotEmpty;

    // Sort attendance history: most recent first
    final attendanceHistory = List<Session>.from(recordedSessions);
    attendanceHistory.sort((a, b) => b.date.compareTo(a.date));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateHeader(today, weekNumber),
          const SizedBox(height: 16),
          if (isAtRisk) _buildWarningBanner(attendancePercent),
          if (isAtRisk) const SizedBox(height: 16),
          _buildStatsRow(
            attendancePercent,
            pendingCount,
            upcomingAssignments.length,
          ),
          const SizedBox(height: 24),

          // TODAY'S SESSIONS
          _buildSectionTitle("Today's Sessions"),
          const SizedBox(height: 8),
          if (todaySessions.isEmpty)
            _buildEmptyMessage("No sessions scheduled for today")
          else
            ...todaySessions.map((s) => _buildSessionTile(s)),

          const SizedBox(height: 24),

          // UPCOMING ASSIGNMENTS
          _buildSectionTitle("Assignments Due This Week"),
          const SizedBox(height: 8),
          if (upcomingAssignments.isEmpty)
            _buildEmptyMessage("No upcoming assignments due this week")
          else
            ...upcomingAssignments.map((a) => _buildAssignmentTile(a)),

          const SizedBox(height: 24),

          // ===== ATTENDANCE HISTORY =====
          _buildSectionTitle(
            "Attendance History ($presentCount present, $absentCount absent)",
          ),
          const SizedBox(height: 8),
          if (attendanceHistory.isEmpty)
            _buildEmptyMessage("No attendance recorded yet")
          else
            ...attendanceHistory
                .take(10) // Show last 10 records
                .map((s) => _buildAttendanceHistoryTile(s)),

          // Show "and X more" if there are more than 10
          if (attendanceHistory.length > 10)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Center(
                child: Text(
                  'and ${attendanceHistory.length - 10} more sessions recorded',
                  style: const TextStyle(
                    color: ALUColors.lightGrey,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ----- HELPER WIDGETS -----

  Widget _buildDateHeader(DateTime today, int weekNumber) {
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayNames[today.weekday - 1],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ALUColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${monthNames[today.month - 1]} ${today.day}, ${today.year}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: ALUColors.lightGrey,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: ALUColors.gold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Week $weekNumber',
                style: const TextStyle(
                  color: ALUColors.navy,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningBanner(double attendance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ALUColors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: ALUColors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'AT RISK: Your attendance is ${attendance.toStringAsFixed(1)}% '
              '(below 75% threshold)',
              style: const TextStyle(
                color: ALUColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(double attendance, int pending, int upcoming) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Attendance',
            '${attendance.toStringAsFixed(0)}%',
            attendance < 75 ? ALUColors.red : ALUColors.green,
            Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Pending',
            '$pending',
            ALUColors.gold,
            Icons.assignment_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Due Soon',
            '$upcoming',
            Colors.orange,
            Icons.schedule,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: ALUColors.lightGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: ALUColors.white,
      ),
    );
  }

  Widget _buildEmptyMessage(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            message,
            style: const TextStyle(color: ALUColors.lightGrey),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionTile(Session session) {
    final timeStr =
        '${Session.formatTime(session.startTime)} - ${Session.formatTime(session.endTime)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _getSessionIcon(session.sessionType),
        title: Text(
          session.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: ALUColors.white,
          ),
        ),
        subtitle: Text(
          '$timeStr${session.location.isNotEmpty ? ' • ${session.location}' : ''}',
          style: const TextStyle(color: ALUColors.lightGrey),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: ALUColors.gold.withAlpha(50),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            session.sessionType,
            style: const TextStyle(fontSize: 11, color: ALUColors.gold),
          ),
        ),
      ),
    );
  }

  Widget _getSessionIcon(String type) {
    IconData icon;
    switch (type) {
      case 'Class':
        icon = Icons.school;
      case 'Mastery Session':
        icon = Icons.psychology;
      case 'Study Group':
        icon = Icons.groups;
      case 'PSL Meeting':
        icon = Icons.handshake;
      default:
        icon = Icons.event;
    }
    return CircleAvatar(
      backgroundColor: ALUColors.gold.withAlpha(50),
      child: Icon(icon, color: ALUColors.gold, size: 20),
    );
  }

  Widget _buildAssignmentTile(Assignment assignment) {
    final todayDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final dueDate = DateTime(
      assignment.dueDate.year,
      assignment.dueDate.month,
      assignment.dueDate.day,
    );
    final daysLeft = dueDate.difference(todayDate).inDays;

    final urgencyColor = daysLeft <= 1
        ? ALUColors.red
        : (daysLeft <= 3 ? Colors.orange : ALUColors.green);

    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPriorityColor(assignment.priority).withAlpha(50),
          child: Text(
            assignment.priority[0],
            style: TextStyle(
              color: _getPriorityColor(assignment.priority),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          assignment.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: ALUColors.white,
          ),
        ),
        subtitle: Text(
          '${assignment.course} • Due ${monthNames[assignment.dueDate.month - 1]} ${assignment.dueDate.day}',
          style: const TextStyle(color: ALUColors.lightGrey),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: urgencyColor.withAlpha(50),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            daysLeft == 0 ? 'Today' : '${daysLeft}d left',
            style: TextStyle(color: urgencyColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // ===== ATTENDANCE HISTORY TILE =====
  /// Shows a record of past attendance with date, session name, and status
  Widget _buildAttendanceHistoryTile(Session session) {
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dateStr = '${monthNames[session.date.month - 1]} ${session.date.day}';
    final isPresent = session.isPresent == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        dense: true,
        // Date on the left
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dateStr,
              style: const TextStyle(color: ALUColors.lightGrey, fontSize: 12),
            ),
          ],
        ),
        // Session name
        title: Text(
          session.title,
          style: const TextStyle(color: ALUColors.white, fontSize: 14),
        ),
        subtitle: Text(
          '${session.sessionType} • ${Session.formatTime(session.startTime)}',
          style: const TextStyle(color: ALUColors.lightGrey, fontSize: 12),
        ),
        // Present/Absent badge
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isPresent
                ? ALUColors.green.withAlpha(50)
                : ALUColors.red.withAlpha(50),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isPresent ? 'Present' : 'Absent',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isPresent ? ALUColors.green : ALUColors.red,
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return ALUColors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return ALUColors.green;
      default:
        return ALUColors.lightGrey;
    }
  }
}
