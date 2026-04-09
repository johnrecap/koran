enum ReaderSessionOwner { general, khatma }

class ReaderSessionIntent {
  const ReaderSessionIntent.general()
      : owner = ReaderSessionOwner.general,
        khatmaId = null;

  const ReaderSessionIntent.khatma(this.khatmaId)
      : owner = ReaderSessionOwner.khatma;

  final ReaderSessionOwner owner;
  final String? khatmaId;

  bool get isKhatmaOwned =>
      owner == ReaderSessionOwner.khatma && (khatmaId?.isNotEmpty ?? false);

  String? get trackedKhatmaId => isKhatmaOwned ? khatmaId : null;
}
