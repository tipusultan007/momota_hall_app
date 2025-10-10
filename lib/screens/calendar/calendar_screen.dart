import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/api_service.dart';
import '../bookings/booking_detail_screen.dart';
import '../../l10n/app_localizations.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final ApiService _apiService = ApiService();
  
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<dynamic>> _events = {};
  List<dynamic> _selectedEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() { _isLoading = true; });
    
    final eventsData = await _apiService.getCalendarEvents();
    final Map<DateTime, List<dynamic>> events = {};
    eventsData.forEach((dateString, eventList) {
      final date = DateTime.parse(dateString);
      events[DateTime.utc(date.year, date.month, date.day)] = eventList;
    });

    if (mounted) {
      setState(() {
        _events = events;
        _selectedEvents = _getEventsForDay(_selectedDay!);
        _isLoading = false;
      });
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents = _getEventsForDay(selectedDay);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingCalendar)),
      body: Column(
        children: [
          _buildTableCalendar(),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildEventList(l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: _onDaySelected,
      eventLoader: _getEventsForDay,
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          shape: BoxShape.circle,
        ),
      ),
      onFormatChanged: (format) {
        if (_calendarFormat != format) setState(() => _calendarFormat = format);
      },
      onPageChanged: (focusedDay) => _focusedDay = focusedDay,
    );
  }
  
  Widget _buildEventList(AppLocalizations l10n) {
    if (_selectedEvents.isEmpty) {
      return Center(child: Text(l10n.noBookingsForDay));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _selectedEvents.length,
      itemBuilder: (context, index) {
        final event = _selectedEvents[index];
        final dueAmount = double.tryParse(event['due_amount']?.replaceAll(',', '') ?? '0') ?? 0;
        
        return Card(
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => BookingDetailScreen(bookingId: event['booking_id'])),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Customer and Time Slot
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event['customer_name'],
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Chip(
                        label: Text(event['time_slot'] == 'Day' ? l10n.slotDay : l10n.slotNight),
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Row 2: Event Type
                  Text(event['event_type'], style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                  const Divider(height: 24),
                  // Row 3: Details (Guests, Tables, Servers)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailItem(l10n.guests, event['guests']?.toString() ?? 'N/A', Icons.people_outline),
                      _buildDetailItem(l10n.tables, event['tables']?.toString() ?? 'N/A', Icons.table_restaurant_outlined),
                      _buildDetailItem(l10n.servers, event['servers']?.toString() ?? 'N/A', Icons.room_service_outlined),
                    ],
                  ),
                  // Row 4: Due Amount (only if there is a due balance)
                  if (dueAmount > 0) ...[
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.dueAmount, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '৳${event['due_amount']}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper widget for the detail items
  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey.shade700),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}