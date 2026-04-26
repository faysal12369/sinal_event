// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

class DateEvent extends StatefulWidget {
  final Function(DateTime?) onDateSelected;
  final DateTime? selectedDate;

  const DateEvent({super.key, required this.onDateSelected, this.selectedDate});

  @override
  State<DateEvent> createState() => _DateEventState();
}

class _DateEventState extends State<DateEvent> {
  List<DateTime?> _selectedDates = [];

  @override
  void initState() {
    super.initState();
    if (widget.selectedDate != null) {
      _selectedDates = [widget.selectedDate];
    }
  }

  @override
  void didUpdateWidget(DateEvent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      setState(() {
        _selectedDates = widget.selectedDate != null
            ? [widget.selectedDate]
            : [];
      });
    }
  }

  String get _formattedDate {
    if (_selectedDates.isEmpty || _selectedDates.first == null) {
      return "Sélectionner la date";
    }
    final date = _selectedDates.first!;
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 800;
    final isTablet = screenSize.width >= 800 && screenSize.width < 1200;

    final isDateSelected =
        _selectedDates.isNotEmpty && _selectedDates.first != null;

    return GestureDetector(
      onTap: () async {
        double dialogWidth = isSmallScreen ? 300 : (isTablet ? 350 : 400);
        double dialogHeight = isSmallScreen ? 350 : 400;

        final results = await showCalendarDatePicker2Dialog(
          context: context,
          config: CalendarDatePicker2WithActionButtonsConfig(
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            calendarType: CalendarDatePicker2Type.single,
            calendarViewScrollPhysics: const BouncingScrollPhysics(),
            dayBorderRadius: BorderRadius.circular(12),
            dayTextStyle: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            selectedDayTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            selectedDayHighlightColor: Colors.blue.shade600,
            todayTextStyle: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
            disabledDayTextStyle: const TextStyle(color: Colors.grey),
            cancelButtonTextStyle: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          dialogSize: Size(dialogWidth, dialogHeight),
          value: _selectedDates,
        );

        if (results != null && results.isNotEmpty) {
          setState(() {
            _selectedDates = results;
          });
          widget.onDateSelected(results.first);
        } else if (results == null || results.isEmpty) {
          setState(() {
            _selectedDates = [];
          });
          widget.onDateSelected(null);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDateSelected ? Colors.blue.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDateSelected ? Colors.blue.shade300 : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 18,
              color: isDateSelected
                  ? Colors.blue.shade600
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              _formattedDate,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isDateSelected ? FontWeight.w600 : FontWeight.w500,
                color: isDateSelected
                    ? Colors.blue.shade700
                    : Colors.grey.shade700,
              ),
            ),
            if (isDateSelected) ...[
              const SizedBox(width: 8),
              Icon(Icons.filter_alt, size: 16, color: Colors.blue.shade600),
            ],
          ],
        ),
      ),
    );
  }
}
