import 'package:jiffy/jiffy.dart';

/// Mixin providing consistent, human-readable date/time formatting
/// across all screens using the Jiffy package.
mixin DateFormatMixin {
  /// Formats as "May 14, 2026".
  String formatDate(DateTime date) {
    return Jiffy.parseFromDateTime(date).format(pattern: 'MMM do, yyyy');
  }

  /// Formats as "May 14 at 2:30 PM".
  String formatDateTime(DateTime dt) {
    return Jiffy.parseFromDateTime(dt).format(pattern: 'MMM do [at] h:mm a');
  }

  /// Formats as "3 days ago", "2 hours ago", "a few seconds ago", etc.
  String formatRelative(DateTime date) {
    return Jiffy.parseFromDateTime(date).fromNow();
  }

  /// Formats as "Mon, May 14".
  String formatShortDate(DateTime date) {
    return Jiffy.parseFromDateTime(date).format(pattern: 'E, MMM do');
  }

  /// Formats as "2:30 PM".
  String formatTime(DateTime dt) {
    return Jiffy.parseFromDateTime(dt).format(pattern: 'h:mm a');
  }
}
