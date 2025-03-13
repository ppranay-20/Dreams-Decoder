import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DreamsTable extends StatefulWidget {
  final Map<DateTime, List<dynamic>> events;
  final Function(DateTime) onDateSelected;

  const DreamsTable({
    super.key,
    required this.events,
    required this.onDateSelected,
  });

  @override
  State<DreamsTable> createState() => _DreamsTableState();
}

class _DreamsTableState extends State<DreamsTable> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF301530),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            rowHeight: 40,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              // Check if the same day is being selected again
              bool isSameDaySelected =
                  _selectedDay != null && isSameDay(_selectedDay!, selectedDay);

              setState(() {
                if (isSameDaySelected) {
                  // If the same day is selected again, clear the selection
                  _selectedDay = null;
                  // Call onDateSelected with a special date to indicate clearing
                  widget.onDateSelected(DateTime(0));
                } else {
                  // Otherwise, update the selection
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;

                  widget.onDateSelected(selectedDay);
                }
              });
            },
            headerStyle: HeaderStyle(
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon:
                    Icon(Icons.chevron_left, color: Colors.white70),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: Colors.white70),
                formatButtonVisible: false,
                titleCentered: true),
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
              rangeStartTextStyle: TextStyle(color: Colors.black),
              rangeStartDecoration: BoxDecoration(
                color: Colors.blue[300],
                shape: BoxShape.circle,
              ),
              rangeEndTextStyle: TextStyle(color: Colors.black),
              rangeEndDecoration: BoxDecoration(
                color: Colors.blue[300],
                shape: BoxShape.circle,
              ),
              withinRangeTextStyle: TextStyle(color: Colors.white),
              withinRangeDecoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
              markerDecoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              weekendStyle:
                  TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
            ),
            eventLoader: (day) {
              DateTime normalizedDay = DateTime(day.year, day.month, day.day);
              return widget.events[normalizedDay] ?? [];
            },
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
