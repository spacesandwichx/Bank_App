import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _money = NumberFormat('#,##0.00', 'en_US');
  static final DateFormat _date = DateFormat('MMM d, HH:mm');

  static String money(num value, {String? currency}) {
    return '${currency ?? AppConstants.currency} ${_money.format(value)}';
  }

  static String signedMoney(num value, {String? currency}) {
    final sign = value < 0 ? '- ' : '+ ';
    return '$sign${currency ?? AppConstants.currency} ${_money.format(value.abs())}';
  }

  static String date(DateTime date) => _date.format(date);
}
