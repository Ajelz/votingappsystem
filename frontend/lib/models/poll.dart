import 'option.dart';
import 'user.dart';

class Poll {
  final int id;
  final String question;
  final int createdBy;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Option> options;

  Poll({
    required this.id,
    required this.question,
    required this.createdBy,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.options,
  });

  factory Poll.fromJson(Map<String, dynamic> json) {
    var optionsFromJson = json['options'] as List;
    List<Option> optionList =
        optionsFromJson.map((i) => Option.fromJson(i)).toList();

    return Poll(
      id: json['id'],
      question: json['question'],
      createdBy: json['created_by'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      options: optionList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'created_by': createdBy,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'options': options.map((option) => option.toJson()).toList(),
    };
  }
}
