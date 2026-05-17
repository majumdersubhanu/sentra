import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentra_ui/sentra_ui.dart';
import 'package:table_calendar/table_calendar.dart';
import '../domain/work_order.dart';
import 'work_orders_view_model.dart';
import '../../../routes/app_router.dart';

@RoutePage()
class WorkOrdersCalendarScreen extends ConsumerStatefulWidget {
  const WorkOrdersCalendarScreen({super.key});

  @override
  ConsumerState<WorkOrdersCalendarScreen> createState() =>
      _WorkOrdersCalendarScreenState();
}

class _WorkOrdersCalendarScreenState
    extends ConsumerState<WorkOrdersCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final workOrdersAsync = ref.watch(localWorkOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Work Order Calendar', style: SentraTypography.h3),
        centerTitle: false,
      ),
      body: workOrdersAsync.when(
        data: (orders) {
          final events = _getEventsForDay(orders);

          return Column(
            children: [
              SentraCard(
                padding: const EdgeInsets.all(SentraSpacing.s),
                child: TableCalendar<WorkOrder>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  eventLoader: (day) =>
                      events[DateTime(day.year, day.month, day.day)] ?? [],
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: SentraColors.primary100,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: SentraColors.primary500,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: SentraColors.primary700,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SentraSpacing.m),
              Expanded(
                child: _buildEventList(
                  events[_selectedDay ??
                          DateTime(
                            _focusedDay.year,
                            _focusedDay.month,
                            _focusedDay.day,
                          )] ??
                      [],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Map<DateTime, List<WorkOrder>> _getEventsForDay(List<WorkOrder> orders) {
    final Map<DateTime, List<WorkOrder>> events = {};
    for (var order in orders) {
      final date = order.scheduledStart ?? order.scheduledDate;
      if (date != null) {
        final day = DateTime(date.year, date.month, date.day);
        events[day] = [...(events[day] ?? []), order];
      }
    }
    return events;
  }

  Widget _buildEventList(List<WorkOrder> dayOrders) {
    if (dayOrders.isEmpty) {
      return Center(
        child: Text(
          'No work orders for this day',
          style: SentraTypography.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: SentraSpacing.m),
      itemCount: dayOrders.length,
      itemBuilder: (context, index) {
        final order = dayOrders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: SentraSpacing.s),
          child: SentraCard(
            onTap: () => context.router.push(
              WorkOrderDetailRoute(workOrderId: order.id),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.title, style: SentraTypography.label),
                      Text(order.id, style: SentraTypography.bodySmall),
                    ],
                  ),
                ),
                SentraBadge(
                  label: order.status.name,
                  type: _getBadgeType(order.status),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  SentraBadgeType _getBadgeType(WorkOrderStatus status) {
    switch (status) {
      case WorkOrderStatus.completed:
      case WorkOrderStatus.verified:
        return SentraBadgeType.success;
      case WorkOrderStatus.inProgress:
        return SentraBadgeType.info;
      case WorkOrderStatus.onHold:
        return SentraBadgeType.warning;
      case WorkOrderStatus.cancelled:
        return SentraBadgeType.error;
      default:
        return SentraBadgeType.neutral;
    }
  }
}
