class Review {
  final String id; 
  String title;
  String? comment; 
  int rating; 

  Review({
    required this.id,
    required this.title,
    this.comment,
    required this.rating,
  }) : assert(rating >= 1 && rating <= 5, 'Rating must be between 1 and 5');

  Review.fromMap(Map<String, Object?> map)
      : id = map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(), 
        title = map['title'] as String,
        comment = map['comment'] as String?,
        rating = map['rating'] as int;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'comment': comment,
      'rating': rating,
    };
  }
}