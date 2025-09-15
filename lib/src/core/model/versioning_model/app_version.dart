class AppVersion {
  final String id;
  final String file;
  final String? text;
  final String version;
  final double size;
  final String created;
  final String updated;
  final bool demo;
  final bool fastfood;
  final String collectionId;

  AppVersion({
    required this.id,
    required this.file,
    required this.text,
    required this.version,
    required this.size,
    required this.created,
    required this.updated,
    required this.demo,
    required this.fastfood,
    required this.collectionId,
  });

  factory AppVersion.fromJson(Map<String, dynamic> json) {
    return AppVersion(
      id: json['id'],
      file: json['file'],
      text: json['text'],
      version: json['version'],
      size: (json['size'] as num).toDouble(),
      created: json['created'],
      updated: json['updated'],
      collectionId: json['collectionId'],
      demo: json['demo'] ?? false,
      fastfood: json['fastfood'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "file": file,
      "text": text,
      "version": version,
      "size": size,
      "created": created,
      "updated": updated,
      "demo": demo,
      "fastfood": fastfood,
      "collectionId": collectionId,
    };
  }
}
