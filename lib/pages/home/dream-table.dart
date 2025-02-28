import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DreamsTable extends StatefulWidget {
    final Map<DateTime, List<dynamic>> events;
  final Function(DateTime) onDateSelected;

  const DreamsTable({super.key, required this.events, required this.onDateSelected});

  @override
  State<DreamsTable> createState() => _DreamsTableState();
}

class _DreamsTableState extends State<DreamsTable> {
  DateTime _focusedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      _focusedDate = day;
    });
    widget.onDateSelected(day);
  }


  @override
  Widget build(BuildContext context) {
    return 
        TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDate,
                calendarFormat: _calendarFormat,
                rowHeight: 40,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                headerStyle: HeaderStyle(
                  titleTextStyle: TextStyle(
                    color: Colors.white, // Header month/year text color
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white70),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white70),
                  formatButtonVisible: false,
                  titleCentered: true
                ),
                selectedDayPredicate: (day) => isSameDay(day, _focusedDate),
                calendarStyle: CalendarStyle(
                   weekendTextStyle: TextStyle(color: Colors.white70),
                    defaultTextStyle: TextStyle(color: Colors.white),
                    weekendDecoration: BoxDecoration(shape: BoxShape.circle),
                    todayTextStyle: TextStyle(color: Colors.black),
                      todayDecoration: BoxDecoration(
                        color: Colors.white70,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: TextStyle(color: Colors.black),
                      selectedDecoration: BoxDecoration(
                        color: Colors.blue[300],
                        shape: BoxShape.circle,
                      ),
                      
                   
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  weekendStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                ),
                onDaySelected: _onDaySelected,
                eventLoader: (day) {
                  DateTime normalizedDay = DateTime(day.year, day.month, day.day);
                  return widget.events[normalizedDay] ?? [];
                },
        );
  }
}
