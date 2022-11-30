import 'package:equatable/equatable.dart';

class AutogeneratedSavings {
  final List<SavingsModel> results;

  AutogeneratedSavings({required this.results});

  factory AutogeneratedSavings.fromJson(Map<String, dynamic> json) {
    var temp = <SavingsModel>[];
    if (json['results'] != null) {
      temp = <SavingsModel>[];
      json['results'].forEach((v) {
        temp.add(SavingsModel.fromJson(v as Map<String, dynamic>));
      });
    }
    return AutogeneratedSavings(results: temp);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['results'] = results.map((v) => v.toJson()).toList();
    return data;
  }
}

class SavingsModel extends Equatable {
  final int id;
  final String name;

  const SavingsModel(this.id, this.name);

  @override
  List<Object> get props => [id, name];

  factory SavingsModel.fromJson(Map<String, dynamic> json) {
    return SavingsModel(json['id'] as int, json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}