import 'package:equatable/equatable.dart';

/// generate by https://javiercbk.github.io/json_to_dart/
class AutogeneratedTransaction {
  final List<TransactionModel> results;

  AutogeneratedTransaction({required this.results});

  factory AutogeneratedTransaction.fromJson(Map<String, dynamic> json) {
    var temp = <TransactionModel>[];
    if (json['results'] != null) {
      temp = <TransactionModel>[];
      json['results'].forEach((v) {
        temp.add(TransactionModel.fromJson(v as Map<String, dynamic>));
      });
    }
    return AutogeneratedTransaction(results: temp);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['results'] = results.map((v) => v.toJson()).toList();
    return data;
  }
}

class TransactionModel extends Equatable {
  final int id;
  final String name;

  const TransactionModel(this.id, this.name);

  @override
  List<Object> get props => [id, name];

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(json['id'] as int, json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
