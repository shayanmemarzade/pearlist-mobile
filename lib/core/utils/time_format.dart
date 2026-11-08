/// Short relative time for activity rows and "Added by …" lines,
/// e.g. "2m ago".
String formatTimeAgo(DateTime at, {DateTime? now}) {
  final diff = (now ?? DateTime.now()).difference(at);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${diff.inDays ~/ 7}w ago';
}

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// When an item was added, as shown on list rows: "Just now", "2m ago",
/// "3h ago", "Yesterday", "Tue", "Oct 12".
String formatItemTime(DateTime at, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final diff = current.difference(at);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';

  final today = DateTime(current.year, current.month, current.day);
  final day = DateTime(at.year, at.month, at.day);
  final days = today.difference(day).inHours ~/ 24;
  if (days <= 0) return '${diff.inHours}h ago';
  if (days == 1) return 'Yesterday';
  if (days < 7) return _weekdays[at.weekday - 1];
  return '${_months[at.month - 1]} ${at.day}';
}
