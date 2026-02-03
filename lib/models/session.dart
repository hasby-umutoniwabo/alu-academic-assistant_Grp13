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
}