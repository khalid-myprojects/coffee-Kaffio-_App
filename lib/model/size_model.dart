class SizeModel {
  final String name;
  final String qty;

  const SizeModel({
    required this.name,
    required this.qty,
  });

  factory SizeModel.fromJson(Map<String, dynamic> json) {
    return SizeModel(
      name: json['name']?.toString() ?? '',
      qty: json['qty']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'qty': qty,
    };
  }
}