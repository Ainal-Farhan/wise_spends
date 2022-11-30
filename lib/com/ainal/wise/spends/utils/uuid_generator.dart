import 'package:uuid/uuid.dart';

class UuidGenerator extends Uuid {
  UuidGenerator._privateConstructor() : super();

  static final _uuidGenerator = UuidGenerator._privateConstructor();

  factory UuidGenerator() {
    return _uuidGenerator;
  }
}
