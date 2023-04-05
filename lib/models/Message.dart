class Message {
  final String title;
  final String keyword;
  final int postId;
  final String link;
  final String date;
  final bool isClicked;

  Message({
    required this.keyword,
    required this.title,
    required this.postId,
    required this.link,
    required this.date,
    this.isClicked = false,
  });

  @override
  String toString() {
    return 'Message{title: $title, keyword: $keyword, postId: $postId, link: $link, date: $date}';
  }

  Message copyWith({
    String? title,
    String? keyword,
    int? postId,
    String? link,
    String? date,
    bool? isClicked,
  }) {
    return Message(
      title: title ?? this.title,
      keyword: keyword ?? this.keyword,
      postId: postId ?? this.postId,
      link: link ?? this.link,
      date: date ?? this.date,
      isClicked: isClicked ?? this.isClicked,
    );
  }
}
