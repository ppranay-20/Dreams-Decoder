import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class DreamsTable extends StatefulWidget {
  final Map<DateTime, List<dynamic>> events;
  final Function(DateTime) onDateSelected;
  final Function clearDateSelected;
  // New properties for date range filter
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
  DateTime? _focusedDate;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  
  // Date range filter variables
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isRangeFilterActive = false;

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      _focusedDate = day;
      
      // Reset range filter when single date is selected
      if (_isRangeFilterActive) {
        _isRangeFilterActive = false;
        _startDate = null;
        _endDate = null;
      }
    });
    widget.onDateSelected(day);
  }

  void _openDateRangePicker() async {
    final initialDateRange = DateTimeRange(
      start: _startDate ?? DateTime.now().subtract(const Duration(days: 7)),
      end: _endDate ?? DateTime.now(),
    );

    final pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.blue[300]!,
              onPrimary: Colors.black,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.grey[800],
          ),
          child: child!,
        );
      },
    );

    if (pickedDateRange != null) {
      setState(() {
        _startDate = pickedDateRange.start;
        _endDate = pickedDateRange.end;
        _isRangeFilterActive = true;
        _focusedDate = null; // Reset single date selection
      });
      
      if (widget.onDateRangeSelected != null) {
        widget.onDateRangeSelected!(_startDate!, _endDate!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _focusedDate ?? DateTime.now(),
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
            // Highlight dates in the selected range
            markersMaxCount: 3,
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
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_focusedDate != null || _isRangeFilterActive)
              TextButton(
                onPressed: () {
                  setState(() {
                    _focusedDate = null;
                    _isRangeFilterActive = false;
                    _startDate = null;
                    _endDate = null;
                    widget.clearDateSelected();
                  });
                }, 
                child: Text(
                  "Show all chats", 
                  style: TextStyle(fontSize: 10, color: Colors.white),
                )
              ),
            SizedBox(width: 10),
            TextButton.icon(
              onPressed: _openDateRangePicker,
              icon: Icon(Icons.date_range, color: Colors.white, size: 14),
              label: Text(
                _isRangeFilterActive 
                    ? "${_startDate!.day}/${_startDate!.month} - ${_endDate!.day}/${_endDate!.month}" 
                    : "Date Range",
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue[900],
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}