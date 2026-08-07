/// POST /site-visits/update request body.
class SiteVisitUpdateRequestModel {
  final int id;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String siteAddress;
  final double? areaSqft;
  final String? projectType;
  final double? estimatedBudget;
  final String? preferredProducts;
  final String visitDate;
  final String? notes;
  final List<int>? removeImageIds;
  final List<String>? images;

  const SiteVisitUpdateRequestModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    this.customerEmail,
    required this.siteAddress,
    this.areaSqft,
    this.projectType,
    this.estimatedBudget,
    this.preferredProducts,
    required this.visitDate,
    this.notes,
    this.removeImageIds,
    this.images,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'site_address': siteAddress,
      'visit_date': visitDate,
    };
    if (customerEmail != null && customerEmail!.isNotEmpty) {
      map['customer_email'] = customerEmail;
    }
    if (areaSqft != null) map['area_sqft'] = areaSqft;
    if (projectType != null) map['project_type'] = projectType;
    if (estimatedBudget != null) map['estimated_budget'] = estimatedBudget;
    if (preferredProducts != null) map['preferred_products'] = preferredProducts;
    if (notes != null) map['notes'] = notes;
    if (removeImageIds != null && removeImageIds!.isNotEmpty) {
      map['remove_image_ids'] = removeImageIds;
    }
    if (images != null && images!.isNotEmpty) map['images'] = images;
    return map;
  }
}