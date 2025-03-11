import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DreamsTable extends StatefulWidget {
  final Map<DateTime, List<dynamic>> events;
  final Function(DateTime) onDateSelected;
  final Function clearDateSelected;
  final Function(DateTime, DateTime)? onDateRangeSelected;

  const DreamsTable({
    super.key,
    required this.events,
    required this.onDateSelected,
    required this.clearDateSelected,
    this.onDateRangeSelected,
  });

  @override
  State<DreamsTable> createState() => _DreamsTableState();
}

class _DreamsTableState extends State<DreamsTable> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Date range selection variables
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  bool _isRangeSelectionMode = false;

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

            // Enable range selection
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            rangeSelectionMode: _isRangeSelectionMode
                ? RangeSelectionMode.enforced
                : RangeSelectionMode.disabled,

            // Handle day selection
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                if (_isRangeSelectionMode) {
                  // If already in range selection mode, handle it differently
                  if (_rangeStart == null) {
                    _rangeStart = selectedDay;
                  } else if (_rangeEnd == null) {
                    // Ensure end date is after start date
                    if (selectedDay.isBefore(_rangeStart!)) {
                      _rangeEnd = _rangeStart;
                      _rangeStart = selectedDay;
                    } else {
                      _rangeEnd = selectedDay;
                    }

                    // Complete range selection and notify parent
                    if (_rangeStart != null &&
                        _rangeEnd != null &&
                        widget.onDateRangeSelected != null) {
                      widget.onDateRangeSelected!(_rangeStart!, _rangeEnd!);
                    }
                  } else {
                    // If both start and end are already set, start a new range
                    _rangeStart = selectedDay;
                    _rangeEnd = null;
                  }
                } else {
                  // Regular single date selection
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _rangeStart = null;
                  _rangeEnd = null;
                  widget.onDateSelected(selectedDay);
                }
              });
            },

            // Highlight the range
            onRangeSelected: (start, end, focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
                _rangeStart = start;
                _rangeEnd = end;
                _selectedDay = null; // Clear single day selection

                if (start != null &&
                    end != null &&
                    widget.onDateRangeSelected != null) {
                  widget.onDateRangeSelected!(start, end);
                }
              });
            },

            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_selectedDay != null ||
                _rangeStart != null ||
                _rangeEnd != null)
              TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedDay = null;
                      _rangeStart = null;
                      _rangeEnd = null;
                      _isRangeSelectionMode = false;
                      widget.clearDateSelected();
                    });
                  },
                  child: Text(
                    "Show all chats",
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  )),
            SizedBox(width: 10),
            // Toggle between single date and range selection
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isRangeSelectionMode = !_isRangeSelectionMode;
                  _selectedDay = null;
                  _rangeStart = null;
                  _rangeEnd = null;
                  widget.clearDateSelected();
                });
              },
              icon: Icon(
                  _isRangeSelectionMode
                      ? Icons.calendar_today
                      : Icons.date_range,
                  color: Colors.white,
                  size: 14),
              label: Text(
                _isRangeSelectionMode ? "Single Date Mode" : "Date Range Mode",
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: _isRangeSelectionMode
                    ? Colors.green[800]
                    : Colors.blue[900],
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),

            if (_isRangeSelectionMode && _rangeStart != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  _rangeEnd != null
                      ? "${_rangeStart!.day}/${_rangeStart!.month} - ${_rangeEnd!.day}/${_rangeEnd!.month}"
                      : "Select end date",
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
