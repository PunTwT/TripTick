// lib/utils/format_helper.dart
// Small functions that turn dates and money into nice text.

import 'package:intl/intl.dart';

String formatDate(DateTime? date) =>
    date == null ? '' : DateFormat('d MMM yyyy').format(date);

String formatMoney(num value) => NumberFormat('#,##0.##').format(value);

String dateRangeText(DateTime? start, DateTime? end) {
  if (start == null && end == null) return 'No dates yet';
  if (start != null && end != null) {
    return '${formatDate(start)} – ${formatDate(end)}';
  }
  return formatDate(start ?? end);
}

String budgetText(double? min, double? max, String currency) {
  if (min == null && max == null) return 'No budget set';
  if (min != null && max != null) {
    return '${formatMoney(min)} – ${formatMoney(max)} $currency';
  }
  if (max != null) return 'Up to ${formatMoney(max)} $currency';
  return 'From ${formatMoney(min!)} $currency';
}