import 'option.dart';
import 'poll.dart';

class Vote {
  final int id;
  final Poll poll;
  final Option selectedOption;

  Vote({
    required this.id,
    required this.poll,
    required this.selectedOption,
  });

  factory Vote.fromJson(Map<String, dynamic> json) {
    final poll = Poll.fromJson(json['poll'] ?? {});
    final selectedOption =
        poll.options.firstWhere((option) => option.id == json['option_id']);

    return Vote(
      id: json['id'],
      poll: poll,
      selectedOption: selectedOption,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'poll': poll.toJson(),
      'selectedOption': selectedOption.toJson(),
    };
  }
}
