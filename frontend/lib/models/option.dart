class Option {
  final int id;
  final String text;
  final int? voteCount;

  Option({
    required this.id,
    required this.text,
    required this.voteCount,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'],
      text: json['description'],
      voteCount: json['vote_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'vote_count': voteCount,
    };
  }
}
