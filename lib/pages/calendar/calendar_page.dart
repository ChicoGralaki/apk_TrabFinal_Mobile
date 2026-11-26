import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/agenda_event_model.dart';
import '../../repositories/agenda_repository.dart';
import '../../theme/app_theme.dart';
import '../agenda/agenda_widgets.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({
    super.key,
    required this.repository,
    required this.snapshot,
  });
  final AgendaRepository repository;
  final AgendaSnapshot snapshot;
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _format = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.snapshot.events;
    List<AgendaEvent> forDay(DateTime day) =>
        events.where((event) => event.occursOn(day)).toList();
    final selectedEvents = forDay(_selectedDay);
    return Scaffold(
      appBar: AppBar(title: const Text('Calendário')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
        children: [
          TableCalendar<AgendaEvent>(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _format,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Mês',
              CalendarFormat.twoWeeks: '2 sem.',
              CalendarFormat.week: 'Semana',
            },
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) => setState(() {
              _selectedDay = selected;
              _focusedDay = focused;
            }),
            onPageChanged: (focused) => setState(() => _focusedDay = focused),
            onFormatChanged: (format) => setState(() => _format = format),
            eventLoader: forDay,
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: AppColors.primary,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: AppColors.primary,
              ),
            ),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('EEEE, d MMMM', 'pt_BR').format(_selectedDay),
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: 'Adicionar evento neste dia',
                onPressed: () => openEventEditor(
                  context,
                  widget.repository,
                  date: _selectedDay,
                ),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          if (selectedEvents.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 26),
              child: Center(
                child: Text(
                  'Nenhum evento nesta data.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            )
          else
            ...selectedEvents.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AgendaEventCard(
                  event: event,
                  repository: widget.repository,
                  onChanged: () => widget.repository.refresh(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
