import 'package:equatable/equatable.dart';

class LoginModel extends Equatable {
  final int id;
  final String name;

  const LoginModel(this.id, this.name);

  @override
  List<Object> get props => [id, name];
}
