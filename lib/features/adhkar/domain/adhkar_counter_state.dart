class AdhkarCounterState {
  const AdhkarCounterState({
    this.count = 0,
    this.target = 33,
  });

  final int count;
  final int? target;

  factory AdhkarCounterState.fromMap(Map<String, dynamic> map) {
    final rawCount = map['count'];
    final rawTarget = map['target'];
    return AdhkarCounterState(
      count: rawCount is int && rawCount >= 0 ? rawCount : 0,
      target: rawTarget is int && rawTarget > 0 ? rawTarget : null,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'count': count,
      'target': target,
    };
  }

  AdhkarCounterState copyWith({
    int? count,
    int? target,
    bool clearTarget = false,
  }) {
    return AdhkarCounterState(
      count: count ?? this.count,
      target: clearTarget ? null : (target ?? this.target),
    );
  }
}
