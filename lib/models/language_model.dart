class LanguageModel {
  final String name;
  final String code;
  bool isDownloaded;

  LanguageModel({
    required this.name,
    required this.code,
    this.isDownloaded = false,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) => LanguageModel(
    name: json['name'],
    code: json['code'],
    isDownloaded: json['isDownloaded'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'code': code,
    'isDownloaded': isDownloaded,
  };
}
