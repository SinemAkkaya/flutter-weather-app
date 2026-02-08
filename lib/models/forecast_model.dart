class ForecastModel {
  // hem eski hem bugünkü kodların çalışması için isimleri standartlaştırdım farklı farklı isimler kullanmışım yanlışlıkla
  
  final String date;        // eskiden: dayName
  final double temperature;
  final String icon;        // eskiden: iconCode
  final String description; //hava durumu açıklaması (Bulutlu vs.) için lazım burası

  ForecastModel({
    required this.date,
    required this.temperature,
    required this.icon,
    required this.description,
  });

  // JSON'dan gelen veriyi modele çevirmek için gerekli olan kısım
  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    // tarihi olduğu gibi alıyorum ekranda istediğim gibi formatlarım
    final dateText = json['dt_txt'] as String;

    return ForecastModel(
      date: dateText, // artık 'date' değişkenine atıyorum
      temperature: (json['main']['temp'] as num).toDouble(),
      icon: json['weather'][0]['icon'], // artık 'icon' değişkenine atıyorum
      description: json['weather'][0]['description'], // buras yeni ekledim hava durumunu göstermek için
    );
  }

  String get iconUrl {
    return 'https://openweathermap.org/img/wn/$icon@4x.png';
  }
}