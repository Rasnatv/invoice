/// POST /site-visits/delete request body: {"id": "5"}
class SiteVisitDeleteRequestModel {
  final String id;

  const SiteVisitDeleteRequestModel({required this.id});

  Map<String, dynamic> toJson() => {'id': id};
}