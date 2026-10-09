/// Measurable activity for Business Pulse (spec §9.2–9.3). No sales or
/// revenue figures: the system does not collect them.
class PulseMetrics {
  const PulseMetrics({
    this.profileViews = 0,
    this.productViews = 0,
    this.promotionViews = 0,
    this.notificationsSent = 0,
    this.notificationsOpened = 0,
  });

  final int profileViews;
  final int productViews;
  final int promotionViews;
  final int notificationsSent;
  final int notificationsOpened;

  /// Open rate in percent; null when nothing has been sent (no data).
  double? get openRate => notificationsSent == 0
      ? null
      : notificationsOpened / notificationsSent * 100;
}
