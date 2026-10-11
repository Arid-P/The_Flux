enum FocusBlockAction {
  create,
  update,
  delete,
}

/// Request received from FluxDo via MethodChannel IPC per GMP_FF_BUILD.md Step 22.
class FocusBlockRequest {
  final FocusBlockAction action;
  final String fdTaskId;
  final String name;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final int? plannedDurationMinutes;

  const FocusBlockRequest({
    required this.action,
    required this.fdTaskId,
    this.name = 'Focus Session',
    this.scheduledStart,
    this.scheduledEnd,
    this.plannedDurationMinutes,
  });

  factory FocusBlockRequest.fromMap(Map<dynamic, dynamic> map) {
    final actionStr = (map['action'] as String? ?? 'create').toLowerCase();
    final action = switch (actionStr) {
      'update' => FocusBlockAction.update,
      'delete' => FocusBlockAction.delete,
      _ => FocusBlockAction.create,
    };

    final startMs = map['scheduledStart'] as int?;
    final endMs = map['scheduledEnd'] as int?;

    return FocusBlockRequest(
      action: action,
      fdTaskId: map['fdTaskId'] as String? ?? '',
      name: map['name'] as String? ?? 'Focus Session',
      scheduledStart: startMs != null ? DateTime.fromMillisecondsSinceEpoch(startMs) : null,
      scheduledEnd: endMs != null ? DateTime.fromMillisecondsSinceEpoch(endMs) : null,
      plannedDurationMinutes: map['plannedDurationMinutes'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'action': action.name,
      'fdTaskId': fdTaskId,
      'name': name,
      'scheduledStart': scheduledStart?.millisecondsSinceEpoch,
      'scheduledEnd': scheduledEnd?.millisecondsSinceEpoch,
      'plannedDurationMinutes': plannedDurationMinutes,
    };
  }
}
