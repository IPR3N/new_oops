class MarketplaceListing {
  final int id;
  final int projectId;
  final int quantity;
  final DateTime listingDate;
  final String status;

  MarketplaceListing({
    required this.id,
    required this.projectId,
    required this.quantity,
    required this.listingDate,
    required this.status,
  });
}