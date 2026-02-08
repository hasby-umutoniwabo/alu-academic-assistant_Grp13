import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/assignment.dart';
import 'models/session.dart';
import 'screens/dashboard_screen.dart';
import 'screens/assignments_screen.dart';
import 'screens/schedule_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(const ALUAcademicApp());
}

class ALUAcademicApp extends StatelessWidget {
  const ALUAcademicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALU Academic Assistant',
      theme: aluTheme,

      debugShowCheckedModeBanner: false,
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  List<Assignment> _assignments = [];
  List<Session> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final assignmentsJson = prefs.getString('assignments');
      if (assignmentsJson != null) {
        final List<dynamic> decoded = jsonDecode(assignmentsJson);
        _assignments = decoded.map((map) => Assignment.fromMap(map)).toList();
      }

      final sessionsJson = prefs.getString('sessions');
      if (sessionsJson != null) {
        final List<dynamic> decoded = jsonDecode(sessionsJson);
        _sessions = decoded.map((map) => Session.fromMap(map)).toList();
      }

      setState(() {});
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final assignmentsJson =
          jsonEncode(_assignments.map((a) => a.toMap()).toList());
      await prefs.setString('assignments', assignmentsJson);

      // Convert sessions list to JSON and save
      final sessionsJson =
          jsonEncode(_sessions.map((s) => s.toMap()).toList());
      await prefs.setString('sessions', sessionsJson);
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  // ===== CALLBACK: Called by child screens when data changes =====
  // This method is passed to child screens so they can notify us
  // when they add, edit, or delete data
  void _onDataChanged() {
    setState(() {}); // Rebuild the UI
    _saveData(); // Save to persistent storage
  }

  @override
  Widget build(BuildContext context) {
    // ===== SCREEN LIST =====
    // These are the 3 screens that correspond to the 3 tabs.
    // The current screen is selected based on _currentIndex.
    final screens = [
      // Tab 0: Dashboard
      DashboardScreen(
        assignments: _assignments,
        sessions: _sessions,
      ),
      // Tab 1: Assignments
      AssignmentsScreen(
        assignments: _assignments,
        onDataChanged: _onDataChanged,
      ),
      // Tab 2: Schedule
      ScheduleScreen(
        sessions: _sessions,
        onDataChanged: _onDataChanged,
      ),
    ];

    // Tab titles for the app bar
    final titles = ['Dashboard', 'Assignments', 'Schedule'];

    return Scaffold(
      // ===== APP BAR =====
      appBar: AppBar(
        title: Text(
          titles[_currentIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // User icon on the right
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // Could show user profile in future
            },
          ),
        ],
      ),

      // ===== BODY: Show the current screen =====
      body: screens[_currentIndex],

      // ===== BOTTOM NAVIGATION BAR =====
      // 3 tabs: Dashboard, Assignments, Schedule
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Switch to the tapped tab
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Assignments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
        ],
      ),
    );
  }
}
