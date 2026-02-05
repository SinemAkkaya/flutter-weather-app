class ForecastModel {
  final String dayName;
  final double temperature;
  final String iconCode;

  ForecastModel({
    required this.dayName,
    required this.temperature,
    required this.iconCode,
  });

  // JSON'dan gelen veriyi modele çevirmek için gerekli olan kısım
  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    //tarihi olduğu gibi alıyorum ekranda istediğim gibi formatlarım
    final dateText = json['dt_txt'] as String;

    return ForecastModel(
      dayName: dateText,
      temperature: (json['main']['temp'] as num).toDouble(),
      iconCode: json['weather'][0]['icon'],
    );
  }

  // İkon linkini oluşturan getter
  String get iconUrl {
    return 'https://openweathermap.org/img/wn/$iconCode@4x.png';
  }
}
