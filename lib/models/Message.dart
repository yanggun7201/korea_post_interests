class Message {
  final String title;
  final String keyword;
  final int postId;
  final String link;
  final String date;

  Message({
    required this.keyword,
    required this.title,
    required this.postId,
    required this.link,
    required this.date,
  });

  @override
  String toString() {
    return 'Message{title: $title, keyword: $keyword, postId: $postId, link: $link, date: $date}';
  }
}
