/// Review summary for the Home dashboard (spec §6.7).
class ReviewSummary {
  const ReviewSummary({required this.count, required this.averageRating});

  const ReviewSummary.empty()
      : count = 0,
        averageRating = 0;

  final int count;
  final double averageRating;

  bool get hasReviews => count > 0;
}
