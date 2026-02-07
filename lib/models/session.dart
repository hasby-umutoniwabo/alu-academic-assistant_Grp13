import 'package:flutter/material.dart';

class Session {
    String id;
    String title;
    DateTime date;
    TimeOfDay startTime;
    TimeOfDay endTime;
    String location;
    String sessionType;
    bool? isPresent;

    //Constructor

    Session({
    String? id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.location = '',
    this.sessionType = 'Class',
    this.isPresent,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  //Helper method to format TimeOfDay as a readable string (09:30 AM)

  static String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  //Convert the session object to a Map for storage

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'startHour': startTime.hour,
      'startMinute': startTime.minute,
      'endHour': endTime.hour,
      'endMinute': endTime.minute,
      'location': location,
      'sessionType': sessionType,
      'isPresent': isPresent,
    };
  }

    //Creates a session object from a Map
    factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      startTime: TimeOfDay(hour: map['startHour'], minute: map['startMinute']),
      endTime: TimeOfDay(hour: map['endHour'], minute: map['endMinute']),
      location: map['location'] ?? '',
      sessionType: map['sessionType'] ?? 'Class',
      isPresent: map['isPresent'],
    );
  }
}