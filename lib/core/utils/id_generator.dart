import 'package:uuid/uuid.dart';

abstract final class IdGenerator {
  static const Uuid _uuid = Uuid();

  static String uniqueId() => _uuid.v4();
}
